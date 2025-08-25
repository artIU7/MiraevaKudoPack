import React, { useState, useEffect, useRef } from 'react';
import './WarehouseOrders.css';
import * as api from '../../utils/api';
import { readCSV } from '../../utils/csv_read';

const WarehouseOrders = () => {

  const [assemblyScale, setAssemblyScale] = useState(1);
  const [assemblyOffset, setAssemblyOffset] = useState({ x: 0, y: 0 });
  const [routeScale, setRouteScale] = useState(1);
  const [routeOffset, setRouteOffset] = useState({ x: 0, y: 0 });
  const [isDraggingAssembly, setIsDraggingAssembly] = useState(false);
  const [isDraggingRoute, setIsDraggingRoute] = useState(false);
  const [startDragPos, setStartDragPos] = useState({ x: 0, y: 0 });

  const MIN_SCALE = 0.1;
  const MAX_SCALE = 3;

  const assemblyCanvasRef = useRef(null);
  const routeCanvasRef = useRef(null);
  
  const [warehouses, setWarehouses] = useState([]);
  const [selectedWarehouse, setSelectedWarehouse] = useState(null);
  
  const [orders, setOrders] = useState([]);
  const [selectedOrder, setSelectedOrder] = useState(null);
  
  const [orderItems, setOrderItems] = useState([]);
  const [selectedOrderItem, setSelectedOrderItem] = useState(null);
  
  const [orderParams, setOrderParams] = useState([]);
  const [selectedOrderParam, setSelectedOrderParam] = useState(null);
  
  const [boxes, setBoxes] = useState([]);
  
  const [sections, setSections] = useState([]);
  const [points, setPoints] = useState([]);
  const [edges, setEdges] = useState([]);
  
  const [pallets, setPallets] = useState([]);
  const [selectedPallet, setSelectedPallet] = useState(null);
  const [selectedLayer, setSelectedLayer] = useState(null);
  const [selectedBox, setSelectedBox] = useState(null);
  
  const [activeTab, setActiveTab] = useState('composition');
  const [resultTab, setResultTab] = useState('assembly');
  
  const [orderForm, setOrderForm] = useState({
    order_name: `Заказ от ${new Date().toLocaleString()}`
  });
  
  const [orderItemForm, setOrderItemForm] = useState({
    name_box: '',
    count_box: 1
  });
  
  const [orderParamForm, setOrderParamForm] = useState({
    pallet_width: 0,
    pallet_length: 0,
    pallet_max_height: 0,
    height_tolerance: 0,
    min_layer_fill_ratio: 0.0,
    min_support_ratio: 0.0,
    packing_type: 0,
    height_layer_diff: 0
  });
  
  const [error, setError] = useState(null);
  const [selectedStartPoint, setSelectedStartPoint] = useState(null);

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
      setOrders([]);
      return;
    }
    
    const loadOrders = async () => {
      try {
        const ordersData = await api.fetchOrdersByWarehouse(selectedWarehouse.id);
        setOrders(ordersData);
      } catch (error) {
        setError('Ошибка загрузки заказов');
      }
    };
    
    loadOrders();
  }, [selectedWarehouse]);

  useEffect(() => {
    if (!selectedWarehouse?.id) {
      setBoxes([]);
      setSections([]);
      setPoints([]);
      setEdges([]);
      return;
    }
    
    const loadData = async () => {
      try {
        const [boxesData, sectionsData, pointsData, edgesData] = await Promise.all([
          api.fetchBoxesByWarehouse(selectedWarehouse.id),
          api.fetchWarehouseSectionGeometries(selectedWarehouse.id),
          api.fetchWarehousePoints(selectedWarehouse.id),
          api.fetchWarehouseEdges(selectedWarehouse.id)
        ]);
        
        setBoxes(boxesData);
        setSections(sectionsData);
        setPoints(pointsData);
        setEdges(edgesData);
      } catch (error) {
        setError('Ошибка загрузки данных склада');
      }
    };
    
    loadData();
  }, [selectedWarehouse]);

  useEffect(() => {
    if (!selectedOrder?.id) {
      setOrderItems([]);
      setOrderParams([]);
      return;
    }
    
    const loadOrderData = async () => {
      try {
        const [itemsData, paramsData] = await Promise.all([
          api.fetchOrderItems(selectedOrder.id),
          api.fetchOrderParams(selectedOrder.id)
        ]);
        
        setOrderItems(itemsData);
        setOrderParams(paramsData);
      } catch (error) {
        setError('Ошибка загрузки данных заказа');
      }
    };
    
    loadOrderData();
  }, [selectedOrder]);

  useEffect(() => {
    if (!selectedOrder?.id || !selectedWarehouse?.id) {
      setPallets([]);
      return;
    }
    
    const loadPallets = async () => {
      try {
        const palletsData = await api.fetchPallets(selectedWarehouse.id, selectedOrder.id);
        setPallets(palletsData);
      } catch (error) {
        setError('Ошибка загрузки паллет');
      }
    };
    
    loadPallets();
  }, [selectedOrder, selectedWarehouse]);

  useEffect(() => {
    if (resultTab === 'assembly' && selectedPallet) {
      handleAssemblyDoubleClick();
    }
    if (resultTab === 'route' && selectedWarehouse) {
      handleRouteDoubleClick();
    }
  }, [resultTab, selectedPallet, selectedWarehouse]);
  

useEffect(() => {
  const canvas = assemblyCanvasRef.current;
  if (!canvas || !selectedPallet) return;
  
  const ctx = canvas.getContext('2d');
  if (!ctx) return;

  ctx.clearRect(0, 0, canvas.width, canvas.height);

  const centerOffsetX = (canvas.width - selectedPallet.widthPallete * assemblyScale) / 2;
  const centerOffsetY = (canvas.height - selectedPallet.lengthPallete * assemblyScale) / 2;

   ctx.strokeStyle = '#8B4513'; 
   ctx.lineWidth = 3 * assemblyScale;
   ctx.strokeRect(
     centerOffsetX + assemblyOffset.x,
     centerOffsetY + assemblyOffset.y,
     selectedPallet.widthPallete * assemblyScale,
     selectedPallet.lengthPallete * assemblyScale
   );
   ctx.fillStyle = '#d4b483';
   ctx.fillRect(
      centerOffsetX + assemblyOffset.x,
      centerOffsetY + assemblyOffset.y,
      selectedPallet.widthPallete * assemblyScale,
      selectedPallet.lengthPallete * assemblyScale
   );
   
    selectedPallet.layers.forEach(layer => {
      if (!selectedLayer || selectedLayer.id === layer.id)
        {
      if (layer.boxed) {
        const sortedBoxes = [...layer.boxed].sort((a, b) => a.orderPrior - b.orderPrior);
        
          sortedBoxes.forEach(box => {
          //const boxWidth = box.orientation === 0 ? box.width_box : box.length_box;
          //const boxLength = box.orientation === 0 ? box.length_box : box.width_box;

          let boxWidth, boxLength, boxHeight;
        
        switch(box.orientation) {
            case 0: // normal (width, length, height)
                boxWidth = box.width_box;
                boxLength = box.length_box;
                boxHeight = box.height_box;
                break;
            case 1: // rotated (length, width, height)
                boxWidth = box.length_box;
                boxLength = box.width_box;
                boxHeight = box.height_box;
                break;
            case 2: // onside_normal (width, height, length)
                boxWidth = box.width_box;
                boxLength = box.height_box;
                boxHeight = box.length_box;
                break;
            case 3: // onside_rotated (height, width, length)
                boxWidth = box.height_box;
                boxLength = box.width_box;
                boxHeight = box.length_box;
                break;
            case 4: // onfront_normal (height, length, width)
                boxWidth = box.height_box;
                boxLength = box.length_box;
                boxHeight = box.width_box;
                break;
            case 5: // onfront_rotated (length, height, width)
                boxWidth = box.length_box;
                boxLength = box.height_box;
                boxHeight = box.width_box;
                break;
            default:
                // Если ориентация неизвестна, используем нормальную
                boxWidth = box.width_box;
                boxLength = box.length_box;
                boxHeight = box.height_box;
        }
          
          const isSelected = selectedBox?.id === box.id && 
          (!selectedLayer || selectedLayer.id === layer.id) &&
          selectedBox?.orderPrior === box.orderPrior;
          
          ctx.fillStyle = isSelected ? '#ff4757' :  (selectedLayer ? '#6c757d' : 'rgba(108, 117, 125, 0.5)');
          ctx.fillRect(
            centerOffsetX + assemblyOffset.x + box.positionOnPallete.x * assemblyScale,
            centerOffsetY + assemblyOffset.y + box.positionOnPallete.y * assemblyScale,
            boxWidth * assemblyScale,
            boxLength * assemblyScale
          );
          
          ctx.strokeStyle = isSelected ? '#fff' :  (selectedLayer ? '#000' : 'rgb(0, 0, 0)');
          ctx.lineWidth = 2 * assemblyScale;
          ctx.strokeRect(
            centerOffsetX + assemblyOffset.x + box.positionOnPallete.x * assemblyScale,
            centerOffsetY + assemblyOffset.y + box.positionOnPallete.y * assemblyScale,
            boxWidth * assemblyScale,
            boxLength * assemblyScale
          );
          if (selectedLayer || isSelected) {
            ctx.fillStyle = isSelected ? '#fff' : '#000';
            ctx.font = `${Math.min(12, 10 * assemblyScale)}px Arial`;
            ctx.textAlign = 'center';
            ctx.textBaseline = 'middle';
            
            const textX = centerOffsetX + assemblyOffset.x + 
                         box.positionOnPallete.x * assemblyScale + 
                         boxWidth * assemblyScale / 2;
            const textY = centerOffsetY + assemblyOffset.y + 
                         box.positionOnPallete.y * assemblyScale + 
                         boxLength * assemblyScale / 2;
  
            if (isSelected) {
              const text = box.sku_box;
              const textWidth = ctx.measureText(text).width;
              const padding = 2 * assemblyScale;
              
              ctx.fillStyle = 'rgba(0, 0, 0, 0.7)';
              ctx.fillRect(
                textX - textWidth/2 - padding,
                textY - 8 * assemblyScale,
                textWidth + padding*2,
                16 * assemblyScale
              );
            }
            
            ctx.fillStyle = isSelected ? '#fff' : '#000';
            ctx.fillText(box.sku_box, textX, textY);
          }
        });
      }
    }
  });

}, [selectedPallet, selectedBox, assemblyScale, assemblyOffset]);

useEffect(() => {
  const canvas = routeCanvasRef.current;
  if (!canvas || !selectedWarehouse) return;

  const ctx = canvas.getContext('2d');
  if (!ctx) return;

  ctx.clearRect(0, 0, canvas.width, canvas.height);

  const centerOffsetX = (canvas.width - selectedWarehouse.warehouse_width * routeScale) / 2;
  const centerOffsetY = (canvas.height - selectedWarehouse.warehouse_length * routeScale) / 2;

  ctx.fillStyle = '#f0f0f0';
  ctx.fillRect(
    centerOffsetX + routeOffset.x,
    centerOffsetY + routeOffset.y,
    selectedWarehouse.warehouse_width * routeScale,
    selectedWarehouse.warehouse_length * routeScale
  );

  sections.forEach(section => {
    ctx.fillStyle = '#d4e6ff';
    ctx.strokeStyle = '#3a7bd5';
    ctx.lineWidth = 2 * routeScale;
    
    ctx.beginPath();
    ctx.rect(
      centerOffsetX + routeOffset.x + section.x_pos * routeScale,
      centerOffsetY + routeOffset.y + section.y_pos * routeScale,
      section.widht_wsec * routeScale,
      section.lenght_wsec * routeScale
    );
    ctx.fill();
    ctx.stroke();

    const text = section.name_section || `Секция ${section.id}`;
    const textWidth = ctx.measureText(text).width;
    const padding = 4 * routeScale;
  
    const sectionCenterX = centerOffsetX + routeOffset.x + section.x_pos * routeScale + (section.widht_wsec * routeScale) / 2;
    const sectionCenterY = centerOffsetY + routeOffset.y + section.y_pos * routeScale + (section.lenght_wsec * routeScale) / 2;
    
    ctx.fillStyle = 'rgba(255, 255, 255, 0.7)';
    ctx.fillRect(
      sectionCenterX - textWidth/2 - padding,
      sectionCenterY - 10 * routeScale,
     textWidth + padding * 2,
     20 * routeScale
    );

    ctx.fillStyle = '#000';
    ctx.font = `${12 * routeScale}px Arial`;
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';


    ctx.fillText(
      section.name_section || `Секция ${section.id_warehouse_section}`,
      centerOffsetX + routeOffset.x + section.x_pos * routeScale + (section.widht_wsec * routeScale) / 2,
      centerOffsetY + routeOffset.y + section.y_pos * routeScale + (section.lenght_wsec * routeScale) / 2
    );

    if (selectedBox) {
      if (section.id_warehouse_section === selectedBox.id_section) {
        ctx.fillStyle = '#ff4757';
        ctx.fillRect(
          centerOffsetX + routeOffset.x + section.x_pos * routeScale,
          centerOffsetY + routeOffset.y + section.y_pos * routeScale,
          section.widht_wsec * routeScale,
          section.lenght_wsec * routeScale
        );
        
        ctx.fillStyle = '#000';
        ctx.fillText(
          section.name_section || `Секция ${section.id_warehouse_section}`,
          centerOffsetX + routeOffset.x + section.x_pos * routeScale + (section.widht_wsec * routeScale) / 2,
          centerOffsetY + routeOffset.y + section.y_pos * routeScale + (section.lenght_wsec * routeScale) / 2
        );
      }
    }
  });

  if (selectedBox) {
    if (selectedBox.path_to_section && selectedBox.path_to_section.length > 1) {
      ctx.strokeStyle = '#2ed573';
      ctx.lineWidth = 3 * routeScale;
      ctx.beginPath();
      
      const startPoint = points.find(p => p.id === selectedBox.path_to_section[0]);
      if (startPoint) {
        ctx.moveTo(
          centerOffsetX + routeOffset.x + startPoint.pos_x * routeScale,
          centerOffsetY + routeOffset.y + startPoint.pos_y * routeScale
        );
      }
      
      for (let i = 1; i < selectedBox.path_to_section.length; i++) {
        const point = points.find(p => p.id === selectedBox.path_to_section[i]);
        if (point) {
          ctx.lineTo(
            centerOffsetX + routeOffset.x + point.pos_x * routeScale,
            centerOffsetY + routeOffset.y + point.pos_y * routeScale
          );
        }
      }
      
      ctx.stroke();
    }
  }

  points.forEach(point => {
    ctx.fillStyle = '#ff4757';
    ctx.beginPath();
    ctx.arc(
      centerOffsetX + routeOffset.x + point.pos_x * routeScale,
      centerOffsetY + routeOffset.y + point.pos_y * routeScale,
      5 * routeScale,
      0,
      Math.PI * 2
    );
    ctx.fill();
    
    ctx.fillStyle = '#000';
    ctx.font = `${10 * routeScale}px Arial`;
    ctx.textAlign = 'center';
    ctx.textBaseline = 'bottom';
    ctx.fillText(
      point.name_points || `Точка ${point.id}`,
      centerOffsetX + routeOffset.x + point.pos_x * routeScale,
      centerOffsetY + routeOffset.y + point.pos_y * routeScale - 8 * routeScale
    );
  });

}, [selectedBox, sections, points, edges, selectedWarehouse, routeScale, routeOffset]);

const handleAssemblyWheel = (e) => {
  e.preventDefault();
  const delta = e.deltaY > 0 ? -0.1 : 0.1;
  setAssemblyScale(prev => Math.max(MIN_SCALE, Math.min(MAX_SCALE, prev + delta)));
};

const handleAssemblyMouseDown = (e) => {
  if (e.detail > 1) return;
  e.preventDefault();
  setIsDraggingAssembly(true);
  setStartDragPos({
    x: e.clientX - assemblyOffset.x,
    y: e.clientY - assemblyOffset.y
  });
  assemblyCanvasRef.current.style.cursor = 'grabbing';
};

const handleAssemblyDoubleClick = () => {
  if (!selectedPallet) return;
  
  const canvas = assemblyCanvasRef.current;
  if (!canvas) return;

  const scaleX = canvas.width / selectedPallet.widthPallete;
  const scaleY = canvas.height / selectedPallet.lengthPallete;
  const newScale = Math.min(scaleX, scaleY) * 0.5; 
  
  setAssemblyScale(newScale);
  setAssemblyOffset({ x: 0, y: 0 });
};

const handleAssemblyMouseMove = (e) => {
  if (!isDraggingAssembly) return;
  setAssemblyOffset({
    x: e.clientX - startDragPos.x,
    y: e.clientY - startDragPos.y
  });
};

const handleAssemblyMouseUp = () => {
  setIsDraggingAssembly(false);
  assemblyCanvasRef.current.style.cursor = 'grab';
};

const handleAssemblyMouseLeave = () => {
  setIsDraggingAssembly(false);
  assemblyCanvasRef.current.style.cursor = 'grab';
};

const handleRouteWheel = (e) => {
  e.preventDefault();
  const delta = e.deltaY > 0 ? -0.1 : 0.1;
  setRouteScale(prev => Math.max(MIN_SCALE, Math.min(MAX_SCALE, prev + delta)));
};

const handleRouteMouseDown = (e) => {
  if (e.detail > 1) return;
  e.preventDefault();
  setIsDraggingRoute(true);
  setStartDragPos({
    x: e.clientX - routeOffset.x,
    y: e.clientY - routeOffset.y
  });
  routeCanvasRef.current.style.cursor = 'grabbing';
};

const handleRouteDoubleClick = () => {
  if (!selectedWarehouse) return;
  
  const canvas = routeCanvasRef.current;
  if (!canvas) return;

  const scaleX = canvas.width / selectedWarehouse.warehouse_width;
  const scaleY = canvas.height / selectedWarehouse.warehouse_length;
  const newScale = Math.min(scaleX, scaleY) * 0.9; 
  
  setRouteScale(newScale);
  setRouteOffset({ x: 0, y: 0 });
};

const handleRouteMouseMove = (e) => {
  if (!isDraggingRoute) return;
  setRouteOffset({
    x: e.clientX - startDragPos.x,
    y: e.clientY - startDragPos.y
  });
};

const handleRouteMouseUp = () => {
  setIsDraggingRoute(false);
  routeCanvasRef.current.style.cursor = 'grab';
};

const handleRouteMouseLeave = () => {
  setIsDraggingRoute(false);
  routeCanvasRef.current.style.cursor = 'grab';
};

const handleComputedOrder = async () => {
  if (!selectedOrder?.id || !selectedWarehouse?.id) {
    setError('Не выбран заказ или склад');
    return;
  }
  try {
    const response = await api.computedOrder({
      id_order_item: selectedOrder.id,
      id_warehouse: selectedWarehouse.id,
      id_point_start: selectedStartPoint?.id || ""
    });
    const palletsData = await api.fetchPallets(selectedWarehouse.id, selectedOrder.id);
    setPallets(palletsData);      
    setActiveTab('result');
  } catch (error) {
    setError('Ошибка распределения заказа');
  }
};

  const handleWarehouseSelect = (warehouse) => {
    setSelectedWarehouse(warehouse);
    setSelectedOrder(null);
  };

  const handleWarehouseDeselect = () => {
    setSelectedWarehouse(null);
    setSelectedOrder(null);
  };

  const handleOrderSelect = (order) => {
    setSelectedOrder(order);
  };

  const handleOrderDeselect = () => {
    setSelectedOrder(null);
  };

  const handleOrderItemSelect = (item) => {
    setSelectedOrderItem(item);
    setOrderItemForm({
      name_box: item.name_box,
      count_box: item.count_box
    });
  };

  const handleOrderParamSelect = (param) => {
    setSelectedOrderParam(param);
    setOrderParamForm({
      pallet_width: param.pallet_width,
      pallet_length: param.pallet_length,
      pallet_max_height: param.pallet_max_height,
      height_tolerance: param.height_tolerance,
      min_layer_fill_ratio: param.min_layer_fill_ratio,
      min_support_ratio: param.min_support_ratio,
      packing_type: param.packing_type,
      height_layer_diff: param.height_layer_diff
    });
  };

  const handlePalletSelect = (pallet) => {
    setSelectedPallet(pallet);
    setSelectedLayer(null);
    setSelectedBox(null);
    setTimeout(() => handleAssemblyDoubleClick(), 0);
    setTimeout(() => handleRouteDoubleClick(), 0);
  };

  const handleLayerSelect = (layer) => {
    setSelectedLayer(layer);
    setSelectedBox(null);
    setTimeout(() => handleAssemblyDoubleClick(), 0);
    setTimeout(() => handleRouteDoubleClick(), 0);
  };

  const handleBoxSelect = (box) => {
    setSelectedBox(box);
    setTimeout(() => handleAssemblyDoubleClick(), 0);
    setTimeout(() => handleRouteDoubleClick(), 0);
  };

  const handleAddOrder = async () => {
    try {
      const newOrder = await api.createOrder({
        id_warehouse: selectedWarehouse.id,
        order_name: orderForm.order_name,
        pallete_computed: ""
      });
      setOrders([...orders, newOrder]);
    
      setOrderForm({
        order_name: `Заказ от ${new Date().toLocaleString()}`
      });
    } catch (error) {
      setError('Ошибка создания заказа');
    }
  };

  const handleDeleteOrder = async () => {
    if (!selectedOrder) return;
    
    try {
      await api.deleteOrder(selectedOrder.id);
      setOrders(orders.filter(o => o.id !== selectedOrder.id));
      setSelectedOrder(null);
    } catch (error) {
      setError('Ошибка удаления заказа');
    }
  };

  const handleAddOrderItem = async () => {
    try {
      const box_f =  boxes.find(b => b.sku_box === orderItemForm.name_box)
      const newItem = await api.createOrderItem({
        id_order_item: selectedOrder.id,
        id_box: box_f.id,
        count_box: orderItemForm.count_box,
        name_box: orderItemForm.name_box
      });
      setOrderItems([...orderItems, newItem]);
      setOrderItemForm({
        name_box: '',
        count_box: 1
      });
    } catch (error) {
      setError('Ошибка добавления элемента заказа');
    }
  };

  const handleUpdateOrderItem = async () => {
    if (!selectedOrderItem) return;
    
    try {
      const updatedItem = await api.updateOrderItem(selectedOrderItem.id, {
        id_order_item: selectedOrder.id,
        name_box: orderItemForm.name_box,
        count_box: orderItemForm.count_box
      });
      setOrderItems(orderItems.map(item => 
        item.id === updatedItem.id ? updatedItem : item
      ));
    } catch (error) {
      setError('Ошибка обновления элемента заказа');
    }
  };

  const handleDeleteOrderItem = async () => {
    if (!selectedOrderItem) return;
    
    try {
      await api.deleteOrderItem(selectedOrderItem.id);
      setOrderItems(orderItems.filter(item => item.id !== selectedOrderItem.id));
      setSelectedOrderItem(null);
    } catch (error) {
      setError('Ошибка удаления элемента заказа');
    }
  };

  const handleAddOrderParam = async () => {
    try {
      var is_pack_type = 0;
      var is_height_diff = 0;
      if ( orderParamForm.packing_type)
      {
          is_pack_type = 1;
      }
      else
      {
          is_pack_type = 0;
      }
      if ( orderParamForm.height_layer_diff)
        {
          var is_height_diff = 1;
        }
        else
        {
          var is_height_diff = 0;
        }
      const newParam = await api.createOrderParam({
        id_order_item: selectedOrder.id,
        packing_type : is_pack_type,
        height_layer_diff: is_height_diff,
        ...orderParamForm
      });
      setOrderParams([...orderParams, newParam]);
    } catch (error) {
      setError('Ошибка добавления параметров заказа');
    }
  };

  const handleUpdateOrderParam = async () => {
    if (!selectedOrderParam) return;
    
    try {
      const updatedParam = await api.updateOrderParam(selectedOrderParam.id, {
        id_order_item: selectedOrder.id,
        ...orderParamForm
      });
      setOrderParams(orderParams.map(param => 
        param.id === updatedParam.id ? updatedParam : param
      ));
    } catch (error) {
      setError('Ошибка обновления параметров заказа');
    }
  };

  const handleDeleteOrderParam = async () => {
    if (!selectedOrderParam) return;
    
    try {
      await api.deleteOrderParam(selectedOrderParam.id);
      setOrderParams(orderParams.filter(param => param.id !== selectedOrderParam.id));
      setSelectedOrderParam(null);
    } catch (error) {
      setError('Ошибка удаления параметров заказа');
    }
  };

  const handleCSVUpload = async (file) => {
    try {
      const csvData = await readCSV(file);
      const items = csvData.map(item => ({
        id_order_item: selectedOrder.id,
        id_box: boxes.find(b => b.sku_box === item.SKU)?.id || '',
        count_box: parseInt(item.Количество),
        name_box: item.SKU
      }));
      
      const createdItems = await api.createOrderItemsFromCSV(items);
      setOrderItems([...orderItems, ...createdItems]);
    } catch (error) {
      setError('Ошибка загрузки CSV');
    }
  };

  return (
    <div className="orders-container">
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
                key={warehouse.id} 
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

      <div className="orders-content">
        <div className="orders-section">
          <div className="orders-list">
            <h3>Список заказов</h3>
            <table className="orders-table">
              <thead>
                <tr>
                  <th>Название заказа</th>
                </tr>
              </thead>
              <tbody>
                {orders.map(order => (
                  <tr 
                    key={order.id} 
                    onClick={() => handleOrderSelect(order)}
                    onDoubleClick={handleOrderDeselect}
                    className={selectedOrder?.id === order.id ? 'selected' : ''}
                  >
                    <td>{order.order_name}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div className="order-actions">
            <h4>Действия с заказом</h4>
            <div className="form-actions">
              <button onClick={handleAddOrder}>Добавить</button>
              <button 
                onClick={handleDeleteOrder} 
                disabled={!selectedOrder}
              >
                Удалить
              </button>
              <button 
               onClick={handleComputedOrder}
               disabled={!selectedOrder}
              >
               Распределить заказ
             </button>
            </div>
          </div>
        </div>

        {selectedOrder && (
          <div className="order-details">
            <div className="tabs">
              <button 
                className={activeTab === 'composition' ? 'active' : ''}
                onClick={() => setActiveTab('composition')}
              >
                Состав заказа
              </button>
              <button 
                className={activeTab === 'result' ? 'active' : ''}
                onClick={() => setActiveTab('result')}
              >
                Результат расчета
              </button>
            </div>

            {activeTab === 'composition' ? (
              <div className="composition-tab">
                <div className="order-items">
                  <h4>Состав заказа</h4>
                  <table className="items-table">
                    <thead>
                      <tr>
                        <th>Коробка</th>
                        <th>Количество</th>
                      </tr>
                    </thead>
                    <tbody>
                      {orderItems.map(item => (
                        <tr 
                          key={item.id}
                          onClick={() => handleOrderItemSelect(item)}
                          onDoubleClick={() => setSelectedOrderItem(null)}
                          className={selectedOrderItem?.id === item.id ? 'selected' : ''}
                        >
                          <td>{boxes.find(b => b.id === item.id_box)?.sku_box || 'Неизвестно'}</td>
                          <td>{item.count_box}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>

                  <div className="order-item-form">
                    <h4>Редактирование состава</h4>
                    <div className="form-group">
                      <label>Коробка:</label>
                      <select
                        value={orderItemForm.name_box}
                        onChange={(e) => setOrderItemForm({
                          ...orderItemForm,
                          name_box: e.target.value
                        })}
                      >
                        <option value="">Выберите коробку</option>
                        {boxes.map(box => (
                          <option key={box.name_box} value={box.name_box}>
                            {box.sku_box}
                          </option>
                        ))}
                      </select>
                    </div>
                    <div className="form-group">
                      <label>Количество:</label>
                      <input 
                        type="number" 
                        value={orderItemForm.count_box}
                        onChange={(e) => setOrderItemForm({
                          ...orderItemForm,
                          count_box: parseInt(e.target.value) || 0
                        })}
                      />
                    </div>
                    <div className="form-actions">
                      <button onClick={handleAddOrderItem}>Добавить</button>
                      <button 
                        onClick={handleUpdateOrderItem}
                        disabled={!selectedOrderItem}
                      >
                        Обновить
                      </button>
                      <button 
                        onClick={handleDeleteOrderItem}
                        disabled={!selectedOrderItem}
                      >
                        Удалить
                      </button>
                      <label className="csv-upload">
                        Загрузить заказ из файла CSV(warehouse_order_data.csv)
                        <input 
                          type="file" 
                          accept=".csv" 
                          onChange={(e) => handleCSVUpload(e.target.files[0])}
                          style={{ display: 'none' }}
                        />
                      </label>
                      <div className="form-group">
                        <label>Начальная точка маршрута:</label>
                        <select
                        value={selectedStartPoint?.name_points || ''}
                        onChange={(e) => {
                        const point = points.find(p => p.name_points === e.target.value);
                        setSelectedStartPoint(point || null);
                        }}
                        >
                        <option value="">Выберите точку</option>
                          {points.map(point => (
                            <option key={point.name_points} value={point.name_points}>
                            {point.name_points} 
                        </option>
                        ))}
                        </select>
                      </div>
                    </div>
                  </div>
                </div>

                <div className="order-params">
                  <h4>Параметры заказа</h4>
                  <table className="params-table">
                    <thead>
                      <tr>
                        <th>Ширина паллеты</th>
                        <th>Длина паллеты</th>
                        <th>Высота паллеты</th>
                      </tr>
                    </thead>
                    <tbody>
                      {orderParams.map(param => (
                        <tr 
                          key={param.id}
                          onClick={() => handleOrderParamSelect(param)}
                          onDoubleClick={() => setSelectedOrderParam(null)}
                          className={selectedOrderParam?.id === param.id ? 'selected' : ''}
                        >
                          <td>{param.pallet_width}</td>
                          <td>{param.pallet_length}</td>
                          <td>{param.pallet_max_height}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>

                  <div className="order-param-form">
                    <h4>Редактирование параметров</h4>
                    <div className="form-row">
                      <div className="form-group">
                        <label>Ширина паллеты:</label>
                        <input 
                          type="number" 
                          value={orderParamForm.pallet_width}
                          onChange={(e) => setOrderParamForm({
                            ...orderParamForm,
                            pallet_width: parseInt(e.target.value) || 0
                          })}
                        />
                      </div>
                      <div className="form-group">
                        <label>Длина паллеты:</label>
                        <input 
                          type="number" 
                          value={orderParamForm.pallet_length}
                          onChange={(e) => setOrderParamForm({
                            ...orderParamForm,
                            pallet_length: parseInt(e.target.value) || 0
                          })}
                        />
                      </div>
                    </div>
                    <div className="form-row">
                      <div className="form-group">
                        <label>Высота паллеты:</label>
                        <input 
                          type="number" 
                          value={orderParamForm.pallet_max_height}
                          onChange={(e) => setOrderParamForm({
                            ...orderParamForm,
                            pallet_max_height: parseInt(e.target.value) || 0
                          })}
                        />
                      </div>
                      <div className="form-group">
                        <label>Перепад высоты:</label>
                        <input 
                          type="number" 
                          value={orderParamForm.height_tolerance}
                          onChange={(e) => setOrderParamForm({
                            ...orderParamForm,
                            height_tolerance: parseInt(e.target.value) || 0
                          })}
                        />
                      </div>
                    </div>
                    <div className="form-row">
                      <div className="form-group">
                        <label>Заполнение слоя %:</label>
                        <input 
                          type="number" 
                          step="0.01"
                          value={orderParamForm.min_layer_fill_ratio}
                          onChange={(e) => setOrderParamForm({
                            ...orderParamForm,
                            min_layer_fill_ratio: parseFloat(e.target.value) || 0
                          })}
                        />
                      </div>
                      <div className="form-group">
                        <label>Площадь опоры %:</label>
                        <input 
                          type="number" 
                          step="0.01"
                          value={orderParamForm.min_support_ratio}
                          onChange={(e) => setOrderParamForm({
                            ...orderParamForm,
                            min_support_ratio: parseFloat(e.target.value) || 0
                          })}
                        />
                      </div>
                    </div>
                    <div className="form-row">
                      <div className="form-check">
                        <input 
                          type="checkbox" 
                          checked={orderParamForm.packing_type}
                          onChange={(e) => setOrderParamForm({
                            ...orderParamForm,
                            packing_type: e.target.checked ? 1 : 0
                          })}
                        />
                        <label>Упаковка по периметру</label>
                      </div>
                      <div className="form-check">
                        <input 
                          type="checkbox" 
                          checked={orderParamForm.height_layer_diff}
                          onChange={(e) => setOrderParamForm({
                            ...orderParamForm,
                            height_layer_diff: e.target.checked ? 1 : 0
                          })}
                        />
                        <label>Слой разной высоты</label>
                      </div>
                    </div>
                    <div className="form-actions">
                      <button onClick={handleAddOrderParam}>Добавить</button>
                      <button 
                        onClick={handleUpdateOrderParam}
                        disabled={!selectedOrderParam}
                      >
                        Обновить
                      </button>
                      <button 
                        onClick={handleDeleteOrderParam}
                        disabled={!selectedOrderParam}
                      >
                        Удалить
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            ) : (
              <div className="result-tab">
                <div className="pallets-tree">
                  <h4>Паллеты</h4>
                  <div className="tree-view">
                    {Array.isArray(pallets) && pallets.map(pallet => (
                      <div 
                        key={pallet.id} 
                        className={`tree-item ${selectedPallet?.id === pallet.id ? 'selected' : ''}`}
                        onClick={() => handlePalletSelect(pallet)}
                      >
                        <div className="tree-item-header">
                          Паллета {pallet.numpallete} <br /> ({pallet.widthPallete}x{pallet.lengthPallete} см)
                        </div>
                        {selectedPallet?.id === pallet.id && pallet.layers.map(layer => (
                          <div 
                            key={layer.id} 
                            className={`tree-item-child ${selectedLayer?.id === layer.id ? 'selected' : ''}`}
                            onClick={(e) => {
                              e.stopPropagation();
                              handleLayerSelect(layer);
                            }}
                          >
                            <div className="tree-item-header">
                              Слой {layer.numLayer} ({(layer.fillPercentage * 100).toFixed(2)}%)
                            </div>
                            {selectedLayer?.id === layer.id && layer.boxed?.map(box => (
                              <div 
                              key={`${box.id}-${box.orderPrior}`} 
                                className={`tree-item-child ${
                                  selectedBox?.id === box.id && 
                                  selectedLayer?.id === layer.id && 
                                  selectedBox?.orderPrior === box.orderPrior ? 'selected' : ''
                                }`}
                                onClick={(e) => {
                                  e.stopPropagation();
                                  handleBoxSelect(box);
                                }}
                              >
                                {box.sku_box} (Позиция: {box.positionOnPallete.x},{box.positionOnPallete.y})
                              </div>
                            ))}
                          </div>
                        ))}
                      </div>
                    ))}
                  </div>
                </div>

                <div className="result-content">
                  <div className="result-tabs">
                    <button 
                      className={resultTab === 'assembly' ? 'active' : ''}
                      onClick={() => setResultTab('assembly')}
                    >
                      Схема сборки
                    </button>
                    <button 
                      className={resultTab === 'route' ? 'active' : ''}
                      onClick={() => setResultTab('route')}
                    >
                      Маршрут до секции
                    </button>
                  </div>

                  {resultTab === 'assembly' ? (
                    <div className="assembly-view">
                      <canvas 
                        ref={assemblyCanvasRef} 
                        width={600} 
                        height={600}
                        onWheel={handleAssemblyWheel}
                        onMouseDown={handleAssemblyMouseDown}
                        onDoubleClick={handleAssemblyDoubleClick}
                        onMouseMove={handleAssemblyMouseMove}
                        onMouseUp={handleAssemblyMouseUp}
                        onMouseLeave={handleAssemblyMouseLeave}
                        style={{ cursor: 'grab' }}
                      />
                    </div>
                  ) : (
                    <div className="route-view">
                      <canvas 
                        ref={routeCanvasRef} 
                        width={600} 
                        height={600}
                        onWheel={handleRouteWheel}
                        onMouseDown={handleRouteMouseDown}
                        onDoubleClick={handleRouteDoubleClick}
                        onMouseMove={handleRouteMouseMove}
                        onMouseUp={handleRouteMouseUp}
                        onMouseLeave={handleRouteMouseLeave}
                        style={{ cursor: 'grab' }}
                      />
                    </div>
                  )}
                </div>
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
};

export default WarehouseOrders;