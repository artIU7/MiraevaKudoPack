import React, { useEffect, useRef, useState } from 'react';
import './WarehouseState.css';
import * as api from '../../utils/api';

const WarehouseState = () => {
  const canvasRef = useRef(null);
  const containerRef = useRef(null);

  const [scale, setScale] = useState(1);
  const [offset, setOffset] = useState({ x: 0, y: 0 });
  const [canvasSize, setCanvasSize] = useState({ width: 0, height: 0 });
  const [isDragging, setIsDragging] = useState(false);
  const [startDragPos, setStartDragPos] = useState({ x: 0, y: 0 });

  const [warehouses, setWarehouses] = useState([]);
  const [selectedWarehouse, setSelectedWarehouse] = useState(null);
  const [sections, setSections] = useState([]);
  const [points, setPoints] = useState([]);
  const [edges, setEdges] = useState([]);
  const [error, setError] = useState(null);
  
  const [socket, setSocket] = useState(null);
  const [trackingPoints, setTrackingPoints] = useState({});

  const MIN_SCALE = 0.1;
  const MAX_SCALE = 3;

  useEffect(() => {
    const loadWarehouses = async () => {
      try {
        const warehousesData = await api.fetchWarehouses();
        setWarehouses(warehousesData);
      } catch (error) {
        setError('Ошибка загрузки списка складов');
      }
    };
    loadWarehouses();
  }, []);

  useEffect(() => {
    if (!selectedWarehouse?.id) {
      setSections([]);
      setPoints([]);
      setEdges([]);
      return;
    }
    
    const loadWarehouseData = async () => {
      try {
        const [sectionsData, pointsData, edgesData] = await Promise.all([
          api.fetchWarehouseSectionGeometries(selectedWarehouse.id),
          api.fetchWarehousePoints(selectedWarehouse.id),
          api.fetchWarehouseEdges(selectedWarehouse.id)
        ]);
        
        setSections(sectionsData);
        setPoints(pointsData);
        setEdges(edgesData);
      } catch (error) {
        setError('Ошибка загрузки данных склада');
      }
    };
    
    loadWarehouseData();
  }, [selectedWarehouse]);

  useEffect(() => {
    const updateCanvasSize = () => {
      if (containerRef.current && selectedWarehouse) {
        const container = containerRef.current;
        setCanvasSize({
          width: container.clientWidth,
          height: container.clientHeight
        });
        
        const scaleX = container.clientWidth / selectedWarehouse.warehouse_width;
        const scaleY = container.clientHeight / selectedWarehouse.warehouse_length;
        const initialScale = Math.min(scaleX, scaleY) * 0.95;
        
        setScale(initialScale);
        setOffset({ x: 0, y: 0 });
      }
    };

    updateCanvasSize();
    window.addEventListener('resize', updateCanvasSize);

    return () => {
      window.removeEventListener('resize', updateCanvasSize);
    };
  }, [selectedWarehouse]);

  useEffect(() => {
    if (!selectedWarehouse) return;
    
    const ws = new WebSocket('wss://app-kudo.brazil-server.netcraze.pro/track');
    setSocket(ws);

    ws.onopen = () => {
      console.log('WebSocket connected');

      ws.send(JSON.stringify({
        sender: "web",
        id: `web_${selectedWarehouse.id}`,
        location_x: 0,
        location_y: 0
      }));
    };

    ws.onmessage = (event) => {
      try {
        const message = JSON.parse(event.data);
        if (message.sender === "ios") {
          handleWebSocketMessage(message);
        }
      } catch (error) {
        console.error('Error parsing message:', error);
      }
    };

    const handleWebSocketMessage = (message) => {
      setTrackingPoints(prev => ({
        ...prev,
        [message.id]: { 
          id: message.id,
          x: message.location_x,
          y: message.location_y,
          timestamp: new Date()
        }
      }));
    };

    ws.onclose = () => {
      console.log('WebSocket disconnected');
    };

    ws.onerror = (error) => {
      console.error('WebSocket error:', error);
    };

    return () => {
      if (ws.readyState === WebSocket.OPEN) {
        ws.close();
      }
    };
  }, [selectedWarehouse]);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas || !selectedWarehouse) return;
    
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    ctx.clearRect(0, 0, canvas.width, canvas.height);

    const centerOffsetX = (canvas.width - selectedWarehouse.warehouse_width * scale) / 2;
    const centerOffsetY = (canvas.height - selectedWarehouse.warehouse_length * scale) / 2;

    ctx.fillStyle = '#f0f0f0';
    ctx.fillRect(
      centerOffsetX + offset.x,
      centerOffsetY + offset.y,
      selectedWarehouse.warehouse_width * scale,
      selectedWarehouse.warehouse_length * scale
    );

    ctx.fillStyle = '#000';
    ctx.font = `${14 * scale}px Arial`;
    ctx.textAlign = 'center';
    ctx.fillText(
      `${selectedWarehouse.warehouse_width} cm`,
      centerOffsetX + offset.x + selectedWarehouse.warehouse_width * scale / 2,
      centerOffsetY + offset.y + selectedWarehouse.warehouse_length * scale + 20
    );
    
    ctx.fillText(
      `${selectedWarehouse.warehouse_length} cm`,
      centerOffsetX + offset.x + selectedWarehouse.warehouse_width * scale + 20,
      centerOffsetY + offset.y + selectedWarehouse.warehouse_length * scale / 2
    );

    sections.forEach(section => {
      ctx.fillStyle = '#d4e6ff';
      ctx.strokeStyle = '#3a7bd5';
      ctx.lineWidth = 2 * scale;
      
      ctx.beginPath();
      ctx.rect(
        centerOffsetX + offset.x + section.x_pos * scale,
        centerOffsetY + offset.y + section.y_pos * scale,
        section.widht_wsec * scale,
        section.lenght_wsec * scale
      );
      ctx.fill();
      ctx.stroke();
    
      const sectionCenterX = centerOffsetX + offset.x + section.x_pos * scale + (section.widht_wsec * scale) / 2;
      const sectionCenterY = centerOffsetY + offset.y + section.y_pos * scale + (section.lenght_wsec * scale) / 2;
    
      ctx.fillStyle = '#000';
      ctx.font = `${Math.min(14, 12 * scale)}px Arial`; 
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      
      const text = section.name_section || `Секция ${section.id}`;
      const textWidth = ctx.measureText(text).width;
      const padding = 4 * scale;
      
      ctx.fillStyle = 'rgba(255, 255, 255, 0.7)';
      ctx.fillRect(
        sectionCenterX - textWidth/2 - padding,
        sectionCenterY - 10 * scale,
        textWidth + padding * 2,
        20 * scale
      );
      
      ctx.fillStyle = '#000';
      ctx.fillText(text, sectionCenterX, sectionCenterY);
    });

    points.forEach(point => {
      ctx.fillStyle = '#ff4757';
      ctx.beginPath();
      ctx.arc(
        centerOffsetX + offset.x + point.pos_x * scale,
        centerOffsetY + offset.y + point.pos_y * scale,
        5 * scale,
        0,
        Math.PI * 2
      );
      ctx.fill();

      ctx.fillStyle = '#000';
      ctx.font = `${10 * scale}px Arial`;
      ctx.fillText(
        point.name_points,
        centerOffsetX + offset.x + point.pos_x * scale + 10,
        centerOffsetY + offset.y + point.pos_y * scale - 10
      );
    });

    edges.forEach(edge => {
      const pointA = points.find(p => p.id === edge.id_points_from);
      const pointB = points.find(p => p.id === edge.id_points_to);
      
      if (pointA && pointB) {
        ctx.strokeStyle = '#2ed573';
        ctx.lineWidth = 2;
        ctx.beginPath();
        ctx.moveTo(
          centerOffsetX + offset.x + pointA.pos_x * scale,
          centerOffsetY + offset.y + pointA.pos_y * scale
        );
        ctx.lineTo(
          centerOffsetX + offset.x + pointB.pos_x * scale,
          centerOffsetY + offset.y + pointB.pos_y * scale
        );
        ctx.stroke();
      }
    });

    Object.values(trackingPoints).forEach(point => {
      ctx.fillStyle = '#FFD700';
      ctx.beginPath();
      ctx.arc(
        centerOffsetX + offset.x + point.x * scale,
        centerOffsetY + offset.y + point.y * scale,
        8 * scale,
        0,
        Math.PI * 2
      );
      ctx.fill();
      
      ctx.strokeStyle = '#000';
      ctx.lineWidth = 1;
      ctx.stroke();
    
      ctx.fillStyle = '#000';
      ctx.font = `${12 * scale}px Arial`;
      ctx.fillText(
        point.id,
        centerOffsetX + offset.x + point.x * scale + 15 * scale,
        centerOffsetY + offset.y + point.y * scale - 15 * scale
      );
    });

  }, [scale, offset, canvasSize, sections, points, edges, selectedWarehouse, trackingPoints]);

  const handleWheel = (e) => {
    e.preventDefault();
    const delta = e.deltaY > 0 ? -0.1 : 0.1;
    setScale(prev => Math.max(MIN_SCALE, Math.min(MAX_SCALE, prev + delta)));
  };

  const handleMouseDown = (e) => {
    if (e.detail > 1) return;
    e.preventDefault();
    setIsDragging(true);
    setStartDragPos({
      x: e.clientX - offset.x,
      y: e.clientY - offset.y
    });
    canvasRef.current.style.cursor = 'grabbing';
  };

  const handleDoubleClick = () => {
    if (!containerRef.current || !selectedWarehouse) return;
    const container = containerRef.current;
    const scaleX = container.clientWidth / selectedWarehouse.warehouse_width;
    const scaleY = container.clientHeight / selectedWarehouse.warehouse_length;
    const initialScale = Math.min(scaleX, scaleY) * 0.95;
    setScale(initialScale);
    setOffset({ x: 0, y: 0 });
  };

  const handleMouseMove = (e) => {
    if (!isDragging) return;
    setOffset({
      x: e.clientX - startDragPos.x,
      y: e.clientY - startDragPos.y
    });
  };

  const handleMouseUp = () => {
    setIsDragging(false);
    canvasRef.current.style.cursor = 'grab';
  };

  const handleMouseLeave = () => {
    setIsDragging(false);
    canvasRef.current.style.cursor = 'grab';
  };

  const handleWarehouseSelect = (warehouse) => {
    setSelectedWarehouse(warehouse);
    setTrackingPoints({}); 
  };

  const handleWarehouseDeselect = () => {
    setSelectedWarehouse(null);
    setTrackingPoints({});
  };

  return (
    <div className="state-container">
      {error && (
        <div className="error-message" onClick={() => setError(null)}>
          {error}
        </div>
      )}

      <div className="warehouse-list">
        <h3>Список складов</h3>
        <table className="warehouse-table">
          <thead>
            <tr>
              <th>Название склада</th>
            </tr>
          </thead>
          <tbody>
            {warehouses.map(warehouse => (
              <tr 
                key={warehouse.id_warehouse} 
                onClick={() => handleWarehouseSelect(warehouse)}
                onDoubleClick={handleWarehouseDeselect}
                className={selectedWarehouse?.id === warehouse.id ? 'selected' : ''}
              >
                <td>{warehouse.warehouse_name}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <div className="warehouse-content">
        <div 
          ref={containerRef}
          className="canvas-wrapper"
          onWheel={handleWheel}
        >
          {selectedWarehouse ? (
            <canvas
              ref={canvasRef}
              width={canvasSize.width}
              height={canvasSize.height}
              onMouseDown={handleMouseDown}
              onDoubleClick={handleDoubleClick}
              onMouseMove={handleMouseMove}
              onMouseUp={handleMouseUp}
              onMouseLeave={handleMouseLeave}
              className="warehouse-canvas"
              style={{ cursor: 'grab' }}
            />
          ) : (
            <div className="no-warehouse-selected">
              Выберите склад для отображения схемы
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default WarehouseState;