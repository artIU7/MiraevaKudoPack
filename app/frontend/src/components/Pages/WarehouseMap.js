import React, { useEffect, useRef, useState } from 'react';
import './WarehouseMap.css';
import * as api from '../../utils/api';
import * as csv from '../../utils/csv_read';

const WarehouseMap = () => {

  const canvasRef = useRef(null);
  const containerRef = useRef(null);

  const [scale, setScale] = useState(1);
  const [offset, setOffset] = useState({ x: 0, y: 0 });
  const [canvasSize, setCanvasSize] = useState({ width: 0, height: 0 });
  const [isDragging, setIsDragging] = useState(false);
  const [startDragPos, setStartDragPos] = useState({ x: 0, y: 0 });

  const [activeTab, setActiveTab] = useState('scheme');
  const [error, setError] = useState(null);

  const [warehouses, setWarehouses] = useState([]);
  const [selectedWarehouse, setSelectedWarehouse] = useState(null);
  const [sections, setSections] = useState([]);
  const [points, setPoints] = useState([]);
  const [edges, setEdges] = useState([]);
  const [section_data, setSectionsData] = useState([]);

  const [selectedSection, setSelectedSection] = useState(null);
  const [selectedPoint, setSelectedPoint] = useState(null);
  const [selectedEdge, setSelectedEdge] = useState(null);

  const [sectionForm, setSectionForm] = useState({
    name_section: '',
    x_pos: '',
    y_pos: '',
    widht_wsec: '',
    lenght_wsec: '',
    name_point_way: ''
  });
  
  const [pointForm, setPointForm] = useState({
    name_points: '',
    pos_x: '',
    pos_y: ''
  });
  
  const [edgeForm, setEdgeForm] = useState({
    name_points_from: '',
    name_points_to: ''
  });

  const MIN_SCALE = 0.1;
  const MAX_SCALE = 3;
  var warehouseWidth = 0;
  var warehouseHeight = 0;

  useEffect(() => {
    const loadWarehouses = async () => {
      try {
        const warehousesData = await api.fetchWarehouses();
        setWarehouses(warehousesData);
      } catch (error) {
        setError('Ошибка загрузки списка складов');
      } finally {
      }
    };
    loadWarehouses();
  }, []);

  useEffect(() => {
    if (!selectedWarehouse?.id) {
      setSections([]);
      setPoints([]);
      setEdges([]);
      setSectionsData([]);
      return;
    }
    
    const loadWarehouseData = async () => {
      try {
        const [sectionsDataGeometry, pointsData, edgesData,sectionsData] = await Promise.all([
          api.fetchWarehouseSectionGeometries(selectedWarehouse.id),
          api.fetchWarehousePoints(selectedWarehouse.id),
          api.fetchWarehouseEdges(selectedWarehouse.id),
          api.fetchSectionsByWarehouse(selectedWarehouse.id)
        ]);
        
        warehouseWidth = selectedWarehouse.warehouse_width;
        warehouseHeight = selectedWarehouse.warehouse_length;

        setSections(sectionsDataGeometry);
        setPoints(pointsData);
        setEdges(edgesData);
        setSectionsData(sectionsData);
      } catch (error) {
        setError('Ошибка загрузки данных склада');
      } finally {
      }
    };
    
    loadWarehouseData();
  }, [selectedWarehouse]);

  useEffect(() => {
      if (activeTab === 'scheme' && selectedWarehouse) {
        handleDoubleClick();
      }
    }, [activeTab, selectedWarehouse]);

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
      `${ selectedWarehouse.warehouse_width} cm`,
      centerOffsetX + offset.x +  selectedWarehouse.warehouse_width * scale / 2,
      centerOffsetY + offset.y + selectedWarehouse.warehouse_length * scale + 20
    );
    
    ctx.fillText(
      `${selectedWarehouse.warehouse_length} cm`,
      centerOffsetX + offset.x + warehouseWidth * scale + 20,
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
    
      ctx.fillStyle = '#000';
      ctx.font = `${12 * scale}px Arial`;
      ctx.textAlign = 'center';  
      ctx.textBaseline = 'middle'; 
    
      const centerX = centerOffsetX + offset.x + section.x_pos * scale + (section.widht_wsec * scale) / 2;
      const centerY = centerOffsetY + offset.y + section.y_pos * scale + (section.lenght_wsec * scale) / 2;
    
      const text = section.name_section || `Секция ${section.id}`;
      const textWidth = ctx.measureText(text).width;
      const padding = 4 * scale;
      
      ctx.fillStyle = 'rgba(255, 255, 255, 0.7)';
      ctx.fillRect(
        centerX - textWidth/2 - padding,
        centerY - 10 * scale,
        textWidth + padding * 2,
        20 * scale
      );
    
      ctx.fillStyle = '#000';
      ctx.fillText(
        section.name_section || `Секция ${section.id}`, 
        centerX,
        centerY
      );
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
  }, [scale, offset, canvasSize, sections, points, edges,selectedWarehouse]);

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
    resetSelectedItems();
  };

  const handleWarehouseDeselect = () => {
    setSelectedWarehouse(null);
    resetSelectedItems();
  };

  const handleSectionSelect = (section) => {
    setSelectedSection(section);
    setSelectedPoint(null);
    setSelectedEdge(null);
    setSectionForm({
      name_section: section.name_section,
      x_pos: section.x_pos,
      y_pos: section.y_pos,
      widht_wsec: section.widht_wsec,
      lenght_wsec: section.lenght_wsec,
      name_point_way: section.name_point_way
    });
  };

  const handleSectionDeselect = () => {
    setSelectedSection(null);
    setSectionForm({
      name_section: '',
      x_pos: '',
      y_pos: '',
      widht_wsec: '',
      lenght_wsec: '',
      name_point_way: ''
    });
  };

  const handleSectionFormChange = (e) => {
    const { name, value } = e.target;
    setSectionForm(prev => ({ ...prev, [name]: value }));
  };

  const handleAddSection = async () => {
    if (!selectedWarehouse) return;
    try {
      const pointOnWhouse = points.find(p => p.name_points === sectionForm.name_point_way);
      if (!pointOnWhouse) {
        throw new Error(`Точка с именем ${sectionForm.name_point_way} не найдена на складе`);
      }
      const sectionOnWhouse = section_data.find(p => p.section_name === sectionForm.name_section);
      if (!sectionOnWhouse) {
        throw new Error(`Секция с именем ${sectionForm.name_section} не найдена на складе`);
      }
      const newSection = await api.createWarehouseSectionGeometry({
        ...sectionForm,
        id_warehouse: selectedWarehouse.id,
        x_pos: parseInt(sectionForm.x_pos),
        y_pos: parseInt(sectionForm.y_pos),
        widht_wsec: parseInt(sectionForm.widht_wsec),
        lenght_wsec: parseInt(sectionForm.lenght_wsec),
        id_point_way:pointOnWhouse.id,
        id_warehouse_section: sectionOnWhouse.id
      });
      setSections(prev => [...prev, newSection]);
      setSectionForm({
        name_section: '',
        x_pos: '',
        y_pos: '',
        widht_wsec: '',
        lenght_wsec: '',
        name_point_way: ''
      });
    } catch (error) {
      setError('Ошибка добавления секции');
      console.error('Error adding section:', error);
    }
  };

  const handleUpdateSection = async () => {
    if (!selectedSection) return;
    try {
      const updatedSection = await api.updateWarehouseSectionGeometry(
        selectedSection.id,
        {
          ...sectionForm,
          id_warehouse: selectedWarehouse.id,
          x_pos: parseInt(sectionForm.x_pos),
          y_pos: parseInt(sectionForm.y_pos),
          widht_wsec: parseInt(sectionForm.widht_wsec),
          lenght_wsec: parseInt(sectionForm.lenght_wsec),
        }
      );
      setSections(prev => prev.map(s => 
        s.id === selectedSection.id ? updatedSection : s
      ));
    } catch (error) {
      setError('Ошибка обновления секции');
      console.error('Error updating section:', error);
    }
  };

  const handleDeleteSection = async () => {
    if (!selectedSection) return;
    try {
      await api.deleteWarehouseSectionGeometry(selectedSection.id);
      setSections(prev => prev.filter(s => s.id !== selectedSection.id));
      handleSectionDeselect();
    } catch (error) {
      setError('Ошибка удаления секции');
      console.error('Error deleting section:', error);
    }
  };

  const handleSectionCSVUpload = async (e) => {
    const file = e.target.files[0];
    if (!file || !selectedWarehouse) return;
    try {
      const csvData = await csv.readCSV(file);
      const geometries = csv.convertSectionGeometryCSV(csvData, selectedWarehouse.id);
      const sectionsWithIds = geometries.map(section => {
        
        const pointOnWhouse = points.find(p => p.name_points === section.name_point_way);
        if (!pointOnWhouse) {
          throw new Error(`Точка с именем ${section.name_point_way} не найдена на складе`);
        }
        const sectionOnWhouse = section_data.find(p => p.section_name === section.name_section);
        if (!sectionOnWhouse) {
          throw new Error(`Секция с именем ${section.name_section} не найдена на складе`);
        }
        return {
          id_warehouse: selectedWarehouse.id,
          x_pos: parseInt(section.x_pos),
          y_pos: parseInt(section.y_pos),
          widht_wsec: parseInt(section.widht_wsec),
          lenght_wsec: parseInt(section.lenght_wsec),
          id_warehouse_section: sectionOnWhouse.id,
          name_section: section.name_section,
          name_point_way: section.name_point_way,
          id_point_way:pointOnWhouse.id
        };
      });
      const createdSections = await api.createWarehouseSectionGeometriesFromCSV(sectionsWithIds);
      setSections(prev => [...prev, ...createdSections]);
      e.target.value = '';
    } catch (error) {
      setError('Ошибка загрузки CSV секций');
    }
  };

  const handlePointSelect = (point) => {
    setSelectedPoint(point);
    setSelectedSection(null);
    setSelectedEdge(null);
    setPointForm({
      name_points: point.name_points,
      pos_x: point.pos_x,
      pos_y: point.pos_y
    });
  };

  const handlePointDeselect = () => {
    setSelectedPoint(null);
    setPointForm({
      name_points: '',
      pos_x: '',
      pos_y: ''
    });
  };

  const handlePointFormChange = (e) => {
    const { name, value } = e.target;
    setPointForm(prev => ({ ...prev, [name]: value }));
  };

  const handleAddPoint = async () => {
    if (!selectedWarehouse) return;
    try {
      const newPoint = await api.createWarehousePoint({
        ...pointForm,
        id_warehouse: selectedWarehouse.id,
        pos_x: parseInt(pointForm.pos_x),
        pos_y: parseInt(pointForm.pos_y)
      });
      setPoints(prev => [...prev, newPoint]);
      setPointForm({
        name_points: '',
        pos_x: '',
        pos_y: ''
      });
    } catch (error) {
      setError('Ошибка добавления точки');
      console.error('Error adding point:', error);
    }
  };

  const handleUpdatePoint = async () => {
    if (!selectedPoint) return;
    try {
      const updatedPoint = await api.updateWarehousePoint(selectedPoint.id, {
        ...pointForm,
        id_warehouse: selectedWarehouse.id,
        pos_x: parseInt(pointForm.pos_x),
        pos_y: parseInt(pointForm.pos_y)
      });
      setPoints(prev => prev.map(p => 
        p.id === selectedPoint.id ? updatedPoint : p
      ));
    } catch (error) {
      setError('Ошибка обновления точки');
      console.error('Error updating point:', error);
    }
  };

  const handleDeletePoint = async () => {
    if (!selectedPoint) return;
    try {
      await api.deleteWarehousePoint(selectedPoint.id);
      setPoints(prev => prev.filter(p => p.id !== selectedPoint.id));
      handlePointDeselect();
    } catch (error) {
      setError('Ошибка удаления точки');
      console.error('Error deleting point:', error);
    }
  };

  const handlePointCSVUpload = async (e) => {
    const file = e.target.files[0];
    if (!file || !selectedWarehouse) return;
    try {
      const csvData = await csv.readCSV(file);
      const pointsData = csv.convertPointsCSV(csvData, selectedWarehouse.id);
      const createdPoints = await api.createWarehousePointsFromCSV(pointsData);
      setPoints(prev => [...prev, ...createdPoints]);
      e.target.value = '';
    } catch (error) {
      setError('Ошибка загрузки CSV точек');
    }
  };

  const handleEdgeSelect = (edge) => {
    setSelectedEdge(edge);
    setSelectedSection(null);
    setSelectedPoint(null);
    setEdgeForm({
      name_points_from: edge.name_points_from,
      name_points_to: edge.name_points_to
    });
  };

  const handleEdgeDeselect = () => {
    setSelectedEdge(null);
    setEdgeForm({
      name_points_from: '',
      name_points_to: ''
    });
  };

  const handleEdgeFormChange = (e) => {
    const { name, value } = e.target;
    setEdgeForm(prev => ({ ...prev, [name]: value }));
  };

  const handleAddEdge = async () => {
    if (!selectedWarehouse) return;
    const pointFrom = points.find(p => p.name_points === edgeForm.name_points_from);
    const pointTo = points.find(p => p.name_points === edgeForm.name_points_to);
    if (!pointFrom || !pointTo) return;
    
    try {
      const newEdge = await api.createWarehouseEdge({
        id_warehouse: selectedWarehouse.id,
        id_points_from: pointFrom.id,
        id_points_to: pointTo.id,
        name_points_from: edgeForm.name_points_from,
        name_points_to: edgeForm.name_points_to
      });
      setEdges(prev => [...prev, newEdge]);
      setEdgeForm({
        name_points_from: '',
        name_points_to: ''
      });
    } catch (error) {
      setError('Ошибка добавления связи');
      console.error('Error adding edge:', error);
    }
  };

  const handleUpdateEdge = async () => {
    if (!selectedEdge) return;
    const pointFrom = points.find(p => p.name_points === edgeForm.name_points_from);
    const pointTo = points.find(p => p.name_points === edgeForm.name_points_to);
    if (!pointFrom || !pointTo) return;
    
    try {
      const updatedEdge = await api.updateWarehouseEdge(selectedEdge.id, {
        id_warehouse: selectedWarehouse.id,
        id_points_from: pointFrom.id,
        id_points_to: pointTo.id,
        name_points_from: edgeForm.name_points_from,
        name_points_to: edgeForm.name_points_to
      });
      setEdges(prev => prev.map(e => 
        e.id === selectedEdge.id ? updatedEdge : e
      ));
    } catch (error) {
      setError('Ошибка обновления связи');
      console.error('Error updating edge:', error);
    }
  };

  const handleDeleteEdge = async () => {
    if (!selectedEdge) return;
    try {
      await api.deleteWarehouseEdge(selectedEdge.id);
      setEdges(prev => prev.filter(e => e.id !== selectedEdge.id));
      handleEdgeDeselect();
    } catch (error) {
      setError('Ошибка удаления связи');
      console.error('Error deleting edge:', error);
    }
  };

  const handleEdgeCSVUpload = async (e) => {
    const file = e.target.files[0];
    if (!file || !selectedWarehouse) return;
    try {
      const csvData = await csv.readCSV(file);
      const edgesData = csv.convertEdgesCSV(csvData, selectedWarehouse.id, points);
      console.error('Error edge:', edgesData);

      const edgesSet = edgesData.map(edges => {
        const pointfromId = points.find(p => p.name_points === edges.name_points_from);
        if (!pointfromId) {
          throw new Error(`Точка с именем ${edges.name_point_way} не найдена на складе`);
        }
        const pointtoId = points.find(p => p.name_points === edges.name_points_to);
        if (!pointtoId) {
          throw new Error(`Точка с именем ${edges.name_point_way} не найдена на складе`);
        }
        return {
          id_warehouse: selectedWarehouse.id,
          name_points_from: edges.name_points_from,
          name_points_to: edges.name_points_to,
          id_points_from: pointfromId.id,
          id_points_to: pointtoId.id
        };
      });
      //
      const createdEdges = await api.createWarehouseEdgesFromCSV(edgesSet);
      setEdges(prev => [...prev, ...createdEdges]);
      e.target.value = '';
    } catch (error) {
      setError('Ошибка загрузки CSV связей');
    }
  };

  const resetSelectedItems = () => {
    setSelectedSection(null);
    setSelectedPoint(null);
    setSelectedEdge(null);
    setSectionForm({
      name_section: '',
      x_pos: '',
      y_pos: '',
      widht_wsec: '',
      lenght_wsec: '',
      name_point_way: ''
    });
    setPointForm({
      name_points: '',
      pos_x: '',
      pos_y: ''
    });
    setEdgeForm({
      name_points_from: '',
      name_points_to: ''
    });
  };

  return (
    <div className="warehouse-container">
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
        <div className="warehouse-tabs">
          <button 
            className={activeTab === 'scheme' ? 'active' : ''}
            onClick={() => setActiveTab('scheme')}
          >
            Схема склада
          </button>
          <button 
            className={activeTab === 'sections' ? 'active' : ''}
            onClick={() => setActiveTab('sections')}
          >
            Секции склада
          </button>
          <button 
            className={activeTab === 'points' ? 'active' : ''}
            onClick={() => setActiveTab('points')}
          >
            Точки и пути
          </button>
        </div>

        <div className="tab-content">
          {activeTab === 'scheme' && (
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
          )}

          {activeTab === 'sections' && (
            <div className="sections-container">
              <div className="sections-table-container">
                <h4>Секции склада: {selectedWarehouse?.warehouse_name}</h4>
                <table className="data-table">
                  <thead>
                    <tr>
                      <th>Название</th>
                      <th>X позиция</th>
                      <th>Y позиция</th>
                      <th>Ширина</th>
                      <th>Длина</th>
                      <th>Точка графа</th>
                    </tr>
                  </thead>
                  <tbody>
                    {sections.map(section => (
                      <tr 
                        key={section.id_warehouse_section}
                        className={selectedSection?.id === section.id ? 'selected' : ''}
                        onClick={() => handleSectionSelect(section)}
                        onDoubleClick={handleSectionDeselect}
                      >
                        <td>{section.name_section}</td>
                        <td>{section.x_pos}</td>
                        <td>{section.y_pos}</td>
                        <td>{section.widht_wsec}</td>
                        <td>{section.lenght_wsec}</td>
                        <td>{section.name_point_way}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>

              <div className="edit-form">
                <h4>{selectedSection ? 'Редактировать секцию' : 'Добавить секцию'}</h4>
                <div className="form-group">
                  <label>Название ячейки</label>
                  <input
                    type="text"
                    name="name_section"
                    value={sectionForm.name_section}
                    onChange={handleSectionFormChange}
                  />
                </div>
                <div className="form-group">
                  <label>Позиция X (см)</label>
                  <input
                    type="number"
                    name="x_pos"
                    value={sectionForm.x_pos}
                    onChange={handleSectionFormChange}
                  />
                </div>
                <div className="form-group">
                  <label>Позиция Y (см)</label>
                  <input
                    type="number"
                    name="y_pos"
                    value={sectionForm.y_pos}
                    onChange={handleSectionFormChange}
                  />
                </div>
                <div className="form-group">
                  <label>Ширина (см)</label>
                  <input
                    type="number"
                    name="widht_wsec"
                    value={sectionForm.widht_wsec}
                    onChange={handleSectionFormChange}
                  />
                </div>
                <div className="form-group">
                  <label>Длина (см)</label>
                  <input
                    type="number"
                    name="lenght_wsec"
                    value={sectionForm.lenght_wsec}
                    onChange={handleSectionFormChange}
                  />
                </div>
                <div className="form-group">
                  <label>Точка графа</label>
                  <select
                    name="name_point_way"
                    value={sectionForm.name_point_way}
                    onChange={handleSectionFormChange}
                  >
                    <option value="">Выберите точку</option>
                    {points.map(point => (
                      <option key={point.id_points} value={point.name_points}>
                        {point.name_points}
                      </option>
                    ))}
                  </select>
                </div>
                <div className="form-actions">
                  {!selectedSection ? (
                    <>
                      <button onClick={handleAddSection}>Добавить</button>
                      <label className="csv-upload">
                      Загрузить геометрию секций CSV(warehouse_geometry.csv)
                        <input 
                          type="file" 
                          accept=".csv" 
                          onChange={handleSectionCSVUpload} 
                          style={{ display: 'none' }} 
                        />
                      </label>
                    </>
                  ) : (
                    <>
                      <button onClick={handleUpdateSection}>Обновить</button>
                      <button onClick={handleDeleteSection}>Удалить</button>
                    </>
                  )}
                </div>
              </div>
            </div>
          )}

          {activeTab === 'points' && (
            <div className="points-container">
              <div className="points-tables-container">
                <div className="points-table">
                  <h4>Точки склада</h4>
                  <table className="data-table">
                    <thead>
                      <tr>
                        <th>Название</th>
                        <th>X позиция</th>
                        <th>Y позиция</th>
                      </tr>
                    </thead>
                    <tbody>
                      {points.map(point => (
                        <tr 
                          key={point.id}
                          className={selectedPoint?.id === point.id ? 'selected' : ''}
                          onClick={() => handlePointSelect(point)}
                          onDoubleClick={handlePointDeselect}
                        >
                          <td>{point.name_points}</td>
                          <td>{point.pos_x}</td>
                          <td>{point.pos_y}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>

                <div className="edges-table">
                  <h4>Связи между точками</h4>
                  <table className="data-table">
                    <thead>
                      <tr>
                        <th>Точка A</th>
                        <th>Точка B</th>
                      </tr>
                    </thead>
                    <tbody>
                      {edges.map(edge => (
                        <tr 
                          key={edge.id}
                          className={selectedEdge?.id === edge.id ? 'selected' : ''}
                          onClick={() => handleEdgeSelect(edge)}
                          onDoubleClick={handleEdgeDeselect}
                        >
                          <td>{edge.name_points_from}</td>
                          <td>{edge.name_points_to}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>

              <div className="points-edit-forms">
                <div className="edit-form">
                  <h4>{selectedPoint ? 'Редактировать точку' : 'Добавить точку'}</h4>
                  <div className="form-group">
                    <label>Название точки</label>
                    <input
                      type="text"
                      name="name_points"
                      value={pointForm.name_points}
                      onChange={handlePointFormChange}
                    />
                  </div>
                  <div className="form-group">
                    <label>Позиция X (см)</label>
                    <input
                      type="number"
                      name="pos_x"
                      value={pointForm.pos_x}
                      onChange={handlePointFormChange}
                    />
                  </div>
                  <div className="form-group">
                    <label>Позиция Y (см)</label>
                    <input
                      type="number"
                      name="pos_y"
                      value={pointForm.pos_y}
                      onChange={handlePointFormChange}
                    />
                  </div>
                  <div className="form-actions">
                    {!selectedPoint ? (
                      <>
                        <button onClick={handleAddPoint}>Добавить</button>
                        <label className="csv-upload">
                          Загрузить точки из файла CSV(warehouse_points.csv)
                          <input 
                            type="file" 
                            accept=".csv" 
                            onChange={handlePointCSVUpload} 
                            style={{ display: 'none' }} 
                          />
                        </label>
                      </>
                    ) : (
                      <>
                        <button onClick={handleUpdatePoint}>Обновить</button>
                        <button onClick={handleDeletePoint}>Удалить</button>
                      </>
                    )}
                  </div>
                </div>

                <div className="edit-form">
                  <h4>{selectedEdge ? 'Редактировать связь' : 'Добавить связь'}</h4>
                  <div className="form-group">
                    <label>Точка A</label>
                    <select
                      name="name_points_from"
                      value={edgeForm.name_points_from}
                      onChange={handleEdgeFormChange}
                    >
                      <option value="">Выберите точку</option>
                      {points.map(point => (
                        <option key={point.id_points} value={point.name_points}>
                          {point.name_points}
                        </option>
                      ))}
                    </select>
                  </div>
                  <div className="form-group">
                    <label>Точка B</label>
                    <select
                      name="name_points_to"
                      value={edgeForm.name_points_to}
                      onChange={handleEdgeFormChange}
                    >
                      <option value="">Выберите точку</option>
                      {points.map(point => (
                        <option key={point.id_points} value={point.name_points}>
                          {point.name_points}
                        </option>
                      ))}
                    </select>
                  </div>
                  <div className="form-actions">
                    {!selectedEdge ? (
                      <>
                        <button onClick={handleAddEdge}>Добавить</button>
                        <label className="csv-upload">
                          Загрузить связи точек из файла CSV(warehouse_edge.csv)
                          <input 
                            type="file" 
                            accept=".csv" 
                            onChange={handleEdgeCSVUpload} 
                            style={{ display: 'none' }} 
                          />
                        </label>
                      </>
                    ) : (
                      <>
                        <button onClick={handleUpdateEdge}>Обновить</button>
                        <button onClick={handleDeleteEdge}>Удалить</button>
                      </>
                    )}
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default WarehouseMap;