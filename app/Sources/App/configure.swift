import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor
import Leaf


struct LocationMessage: Codable {
    let sender: String 
    let id: String      
    let location_x: Double
    let location_y: Double
}

public func configure(_ app: Application) async throws {

    app.views.use(.leaf)
    app.leaf.cache.isEnabled = app.environment.isRelease
    // Из доки Vapor
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
    )
    let cors = CORSMiddleware(configuration: corsConfiguration)
    app.middleware.use(cors, at: .beginning)

    // Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(UserBasicAuthenticator())

    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "192.168.2.79",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? 5430,
        username: Environment.get("DATABASE_USERNAME") ?? "postgres_user",
        password: Environment.get("DATABASE_PASSWORD") ?? "postgres_password",
        database: Environment.get("DATABASE_NAME") ?? "postgres_db",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)

    app.migrations.add(CreateKudoBoxMigration())
    app.migrations.add(CreateWarehouseDataMigration())
    app.migrations.add(CreateUserDataMigration())
    app.migrations.add(CreateWarehouseSectionMigration())
    app.migrations.add(CreateWarehouseSectionGeometryMigration())
    app.migrations.add(CreateWarehousePointsMigration())
    app.migrations.add(CreateWarehouseEdgeMigration())
    app.migrations.add(CreateOrderDataMigration())
    app.migrations.add(CreateOrderItemMigration())
    app.migrations.add(CreateOrderPakingParamMigration())
    app.migrations.add(CreateAPIDataMigration())

    var connections = [String: WebSocket]()


    // Web Socket для трекинга кладовщика на погрузчике (ipad client) через BLE
    app.webSocket("track") { req, ws in
        ws.onText { ws, text in
            do {
                let message = try JSONDecoder().decode(LocationMessage.self, from: Data(text.utf8))
                if connections[message.id] == nil {
                    connections[message.id] = ws
                }
                for (id, connection) in connections {
                    if id != message.id {
                        let targetType = message.sender == "ios" ? "web" : "ios"
                        if id.hasPrefix(targetType) {
                            try connection.send(text)
                        }
                    }
                }
            } catch {
                print("Error decoding message: \(error)")
            }
        }        
        ws.onClose.whenComplete { _ in
            if let id = connections.first(where: { $0.value === ws })?.key {
                connections.removeValue(forKey: id)
            }
        }
    }
    /*
    // Добавляем тестовый WebSocket для приложения на Qt (Клиент-Kudo.Sklad)
    app.webSocket("update") { req, ws in 
    	ws.onText { ws, text in 
		ws.send("receive: \(text)")
        }
    }
    */
    // Ограничение по загрузке данных в теле запроса
    app.routes.defaultMaxBodySize = "5mb"
    app.http.server.configuration.shutdownTimeout = .minutes(5)
    
    // register routes
    try routes(app)
}
	
