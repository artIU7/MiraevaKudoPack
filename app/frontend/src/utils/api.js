import axios from "axios";

const API_BASE_URL = "https://app-kudo.brazil-server.netcraze.pro/api/v1";

export const login = async (username, password) => {
  try {
    const token = btoa(`${username}:${password}`);
    const response = await axios.post(`${API_BASE_URL}/user_data/login`, null, {
      headers: {
        Authorization: `Basic ${token}`,
        "Content-Type": "application/json"
      },
    });
    return response.data;
  } catch (error) {
    console.error("Login error:", error);
    throw error;
  }
};

export const fetchWarehouseSectionGeometries = async (warehouseId) => {
  const response = await axios.get(`${API_BASE_URL}/warehouse_section_geometry/withWarehouseID/${warehouseId}`);
  return response.data;
};

export const createWarehouseSectionGeometry = async (geometry) => {
  const response = await axios.post(`${API_BASE_URL}/warehouse_section_geometry/`, geometry);
  return response.data;
};

export const createWarehouseSectionGeometriesFromCSV = async (geometries) => {
  const response = await axios.post(`${API_BASE_URL}/warehouse_section_geometry/sections`, geometries);
  return response.data;
};

export const updateWarehouseSectionGeometry = async (id, geometry) => {
  const response = await axios.put(`${API_BASE_URL}/warehouse_section_geometry/${id}`, geometry);
  return response.data;
};

export const deleteWarehouseSectionGeometry = async (id) => {
  const response = await axios.delete(`${API_BASE_URL}/warehouse_section_geometry/${id}`);
  return response.data;
};

export const fetchWarehousePoints = async (warehouseId) => {
  const response = await axios.get(`${API_BASE_URL}/warehouse_points/withWarehouseID/${warehouseId}`);
  return response.data;
};

export const createWarehousePoint = async (point) => {
  const response = await axios.post(`${API_BASE_URL}/warehouse_points/`, point);
  return response.data;
};

export const createWarehousePointsFromCSV = async (points) => {
  const response = await axios.post(`${API_BASE_URL}/warehouse_points/points`, points);
  return response.data;
};

export const updateWarehousePoint = async (id, point) => {
  const response = await axios.put(`${API_BASE_URL}/warehouse_points/${id}`, point);
  return response.data;
};

export const deleteWarehousePoint = async (id) => {
  const response = await axios.delete(`${API_BASE_URL}/warehouse_points/${id}`);
  return response.data;
};

export const fetchWarehouseEdges = async (warehouseId) => {
  const response = await axios.get(`${API_BASE_URL}/warehouse_edge/withWarehouseID/${warehouseId}`);
  return response.data;
};

export const createWarehouseEdge = async (edge) => {
  const response = await axios.post(`${API_BASE_URL}/warehouse_edge/`, edge);
  return response.data;
};

export const createWarehouseEdgesFromCSV = async (edges) => {
  const response = await axios.post(`${API_BASE_URL}/warehouse_edge/edges`, edges);
  return response.data;
};

export const updateWarehouseEdge = async (id, edge) => {
  const response = await axios.put(`${API_BASE_URL}/warehouse_edge/${id}`, edge);
  return response.data;
};

export const deleteWarehouseEdge = async (id) => {
  const response = await axios.delete(`${API_BASE_URL}/warehouse_edge/${id}`);
  return response.data;
};

export const fetchWarehouses = async () => {
  const response = await axios.get(`${API_BASE_URL}/warehouse_data/`);
  return response.data;
};

export const fetchWarehouseById = async (id) => {
  const response = await axios.get(`${API_BASE_URL}/warehouse_data/withWarehouseID/${id}`);
  return response.data;
};

export const createWarehouse = async (warehouse) => {
  const response = await axios.post(`${API_BASE_URL}/warehouse_data/`, warehouse);
  return response.data;
};

export const createWarehousesFromCSV = async (warehouses) => {
  const response = await axios.post(`${API_BASE_URL}/warehouse_data/warehouses`, warehouses);
  return response.data;
};

export const updateWarehouse = async (id, warehouse) => {
  const response = await axios.put(`${API_BASE_URL}/warehouse_data/${id}`, warehouse);
  return response.data;
};

export const deleteWarehouse = async (id) => {
  const response = await axios.delete(`${API_BASE_URL}/warehouse_data/${id}`);
  return response.data;
};

export const fetchBoxesByWarehouse = async (warehouseId) => {
  const response = await axios.get(`${API_BASE_URL}/kudobox/withWarehouseID/${warehouseId}`);
  return response.data;
};

export const createBox = async (box) => {
  const response = await axios.post(`${API_BASE_URL}/kudobox/`, box);
  return response.data;
};

export const createBoxesFromCSV = async (boxes) => {
  const response = await axios.post(`${API_BASE_URL}/kudobox/boxes`, boxes);
  return response.data;
};

export const updateBox = async (id, box) => {
  const response = await axios.put(`${API_BASE_URL}/kudobox/${id}`, box);
  return response.data;
};

export const deleteBox = async (id) => {
  const response = await axios.delete(`${API_BASE_URL}/kudobox/${id}`);
  return response.data;
};

export const fetchSectionsByWarehouse = async (warehouseId) => {
  const response = await axios.get(`${API_BASE_URL}/warehouse_section/withWarehouseID/${warehouseId}`);
  return response.data;
};

export const createSection = async (section) => {
  const response = await axios.post(`${API_BASE_URL}/warehouse_section/`, section);
  return response.data;
};

export const createSectionsFromCSV = async (sections) => {
  const response = await axios.post(`${API_BASE_URL}/warehouse_section/sections`, sections);
  return response.data;
};

export const updateSection = async (id, section) => {
  const response = await axios.put(`${API_BASE_URL}/warehouse_section/${id}`, section);
  return response.data;
};

export const deleteSection = async (id) => {
  const response = await axios.delete(`${API_BASE_URL}/warehouse_section/${id}`);
  return response.data;
};
export const fetchUsersByWarehouse = async (warehouseId) => {
  const response = await axios.get(`${API_BASE_URL}/user_data/withWarehouseID/${warehouseId}`);
  return response.data;
};

export const createUser = async (user) => {
  const response = await axios.post(`${API_BASE_URL}/user_data/`, user);
  return response.data;
};

export const updateUser = async (userId, user) => {
  const response = await axios.put(`${API_BASE_URL}/user_data/${userId}`, user);
  return response.data;
};

export const deleteUser = async (userId) => {
  const response = await axios.delete(`${API_BASE_URL}/user_data/${userId}`);
  return response.data;
};
// Orders API
export const fetchOrdersByWarehouse = async (warehouseId) => {
  const response = await axios.get(`${API_BASE_URL}/order_item/withWarehouseID/${warehouseId}`);
  return response.data;
};

export const createOrder = async (order) => {
  const response = await axios.post(`${API_BASE_URL}/order_item/`, order);
  return response.data;
};

export const deleteOrder = async (orderId) => {
  const response = await axios.delete(`${API_BASE_URL}/order_item/${orderId}`);
  return response.data;
};

export const fetchOrderItems = async (orderId) => {
  const response = await axios.get(`${API_BASE_URL}/order_data/withOrderID/${orderId}`);
  return response.data;
};

export const createOrderItem = async (item) => {
  const response = await axios.post(`${API_BASE_URL}/order_data/`, item);
  return response.data;
};

export const updateOrderItem = async (id, item) => {
  const response = await axios.put(`${API_BASE_URL}/order_data/${id}`, item);
  return response.data;
};

export const deleteOrderItem = async (id) => {
  const response = await axios.delete(`${API_BASE_URL}/order_data/${id}`);
  return response.data;
};

export const createOrderItemsFromCSV = async (items) => {
  const response = await axios.post(`${API_BASE_URL}/order_data/data`, items);
  return response.data;
};

export const fetchOrderParams = async (orderId) => {
  const response = await axios.get(`${API_BASE_URL}/order_param/withOrderID/${orderId}`);
  return response.data;
};

export const createOrderParams = async (params) => {
  const response = await axios.post(`${API_BASE_URL}/order_param/`, params);
  return response.data;
};

export const updateOrderParams = async (id, params) => {
  const response = await axios.put(`${API_BASE_URL}/order_param/${id}`, params);
  return response.data;
};

export const deleteOrderParams = async (id) => {
  const response = await axios.delete(`${API_BASE_URL}/order_param/${id}`);
  return response.data;
};

export const fetchPalletsByOrder = async (warehouseId, orderId) => {
  const response = await axios.get(`${API_BASE_URL}/order_item/withWarehouseID/${warehouseId}/withOrderID/${orderId}`);
  return response.data;
};
export const createOrderParam = async (param) => {
  const response = await axios.post(`${API_BASE_URL}/order_param/`, param);
  return response.data;
};

export const updateOrderParam = async (id, param) => {
  const response = await axios.put(`${API_BASE_URL}/order_param/${id}`, param);
  return response.data;
};

export const deleteOrderParam = async (id) => {
  const response = await axios.delete(`${API_BASE_URL}/order_param/${id}`);
  return response.data;
};

export const computedOrder = async (param) => {
  const response = await axios.post(`${API_BASE_URL}/computed_order/`,param);
  return await response.data;
};
export const fetchPallets = async (warehouseId, orderId) => {
  const response = await axios.get(`${API_BASE_URL}/order_item/withWarehouseID/${warehouseId}/withOrderID/${orderId}`);
  return Object.values(response.data).flat();
};