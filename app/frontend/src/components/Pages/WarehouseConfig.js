import React, { useState, useEffect } from 'react';
import './WarehouseConfig.css';
import * as api from '../../utils/api';
import * as csv from '../../utils/csv_read';

const WarehouseConfig = () => {

  const [warehouses, setWarehouses] = useState([]);
  const [selectedWarehouse, setSelectedWarehouse] = useState(null);
  const [warehouseForm, setWarehouseForm] = useState({
    warehouse_name: '',
    warehouse_width: '',
    warehouse_length: ''
  });

  const [boxes, setBoxes] = useState([]);
  const [selectedBox, setSelectedBox] = useState(null);
  const [boxForm, setBoxForm] = useState({
    sku_box: '',
    width_box: '',
    length_box: '',
    height_box: '',
    weight_box: '',
    is_rotated_box: false,
    max_load_box: ''
  });

  const [sections, setSections] = useState([]);
  const [selectedSection, setSelectedSection] = useState(null);
  const [sectionForm, setSectionForm] = useState({
    section_name: '',
    sku_name: '',
    count_box: ''
  });

  const [activeTab, setActiveTab] = useState('boxes');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    const loadWarehouses = async () => {
      setLoading(true);
      try {
        const data = await api.fetchWarehouses();
        setWarehouses(data);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };
    loadWarehouses();
  }, []);

  useEffect(() => {
    if (selectedWarehouse) {
      const loadData = async () => {
        setLoading(true);
        try {
          const [boxesData, sectionsData] = await Promise.all([
            api.fetchBoxesByWarehouse(selectedWarehouse.id),
            api.fetchSectionsByWarehouse(selectedWarehouse.id)
          ]);
          setBoxes(boxesData);
          setSections(sectionsData);
        } catch (err) {
          setError(err.message);
        } finally {
          setLoading(false);
        }
      };
      loadData();
    }
  }, [selectedWarehouse]);

  const handleWarehouseSelect = (warehouse) => {
    setSelectedWarehouse(warehouse);
    setWarehouseForm({
      warehouse_name: warehouse.warehouse_name,
      warehouse_width: warehouse.warehouse_width,
      warehouse_length: warehouse.warehouse_length
    });
    setSelectedBox(null);
    setSelectedSection(null);
  };

  const handleBoxSelect = (box) => {
    setSelectedBox(box);
    setBoxForm({
      sku_box: box.sku_box,
      width_box: box.width_box,
      length_box: box.length_box,
      height_box: box.height_box,
      weight_box: box.weight_box,
      is_rotated_box: box.is_rotated_box === 1,
      max_load_box: box.max_load_box
    });
  };
  
  const handleSectionSelect = (section) => {
    setSelectedSection(section);
    setSectionForm({
      section_name: section.section_name,
      sku_name: section.sku_name,
      count_box: section.count_box
    });
  };

  const handleWarehouseFormChange = (e) => {
    const { name, value } = e.target;
    setWarehouseForm(prev => ({ ...prev, [name]: value }));
  };

  const handleBoxFormChange = (e) => {
    const { name, value, type, checked } = e.target;
    setBoxForm(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }));
  };

  const handleSectionFormChange = (e) => {
    const { name, value } = e.target;
    setSectionForm(prev => ({ ...prev, [name]: value }));
  };

  const handleWarehouseSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
        const warehouseData = {
            warehouse_name: warehouseForm.warehouse_name,
            warehouse_width: Number(warehouseForm.warehouse_width),
            warehouse_length: Number(warehouseForm.warehouse_length)
        };
        if (selectedWarehouse) {
            await api.updateWarehouse(selectedWarehouse.id, warehouseData);
            const updatedWarehouses = warehouses.map(w => 
              w.id === selectedWarehouse.id ? { ...w, ...warehouseData } : w
            );
            setWarehouses(updatedWarehouses);
          } else {
            const newWarehouse = await api.createWarehouse(warehouseData);
            setWarehouses([...warehouses, newWarehouse]);
            setWarehouseForm({
              warehouse_name: '',
              warehouse_width: '',
              warehouse_length: ''
            });
          }
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleBoxSubmit = async (e) => {
    e.preventDefault();
    if (!selectedWarehouse) return;
    setLoading(true);
    try {
      const boxData = {
        ...boxForm,
        uuid_warehouse: selectedWarehouse.id,
        width_box: Number(boxForm.width_box),
        length_box: Number(boxForm.length_box),
        height_box: Number(boxForm.height_box),
        weight_box: Number(boxForm.weight_box),
        max_load_box: Number(boxForm.max_load_box),
        is_rotated_box: boxForm.is_rotated_box ? 1 : 0
      };
      
      if (selectedBox) {
        await api.updateBox(selectedBox.id, boxData);
        const updatedBoxes = boxes.map(b => 
          b.id === selectedBox.id ? { ...b, ...boxData } : b
        );
        setBoxes(updatedBoxes);
      } else {
        const newBox = await api.createBox(boxData);
        setBoxes([...boxes, newBox]);
        setBoxForm({
          sku_box: '',
          width_box: '',
          length_box: '',
          height_box: '',
          weight_box: '',
          is_rotated_box: false,
          max_load_box: ''
        });
      }
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleSectionSubmit = async (e) => {
    e.preventDefault();
    if (!selectedWarehouse) return;
    setLoading(true);
    try {
      const currentBoxes = await api.fetchBoxesByWarehouse(selectedWarehouse.id);
      const selectedBoxForSection = currentBoxes.find(b => b.sku_box === sectionForm.sku_name);
      if (!selectedBoxForSection) throw new Error('Selected box not found');
      
      const sectionData = {
        ...sectionForm,
        id_warehouse: selectedWarehouse.id,
        id_box: selectedBoxForSection.id,
        count_box: Number(sectionForm.count_box)
      };
      
      if (selectedSection) {
        await api.updateSection(selectedSection.id, sectionData);
        const updatedSections = sections.map(s => 
          s.id === selectedSection.id ? { ...s, ...sectionData } : s
        );
        setSections(updatedSections);
      } else {
        const newSection = await api.createSection(sectionData);
        setSections([...sections, newSection]);
        setSectionForm({
          section_name: '',
          sku_name: '',
          count_box: ''
        });
      }
    } catch (err) {

      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleCSVUpload = async (type, file) => {
    if (!file) return;
    setLoading(true);
    try {
      const csvData = await csv.readCSV(file);
      
      switch (type) {
        case 'warehouse':
          const warehousesData = csv.convertWarehouseCSV(csvData);
          await api.createWarehousesFromCSV(warehousesData);
          const updatedWarehouses = await api.fetchWarehouses();
          setWarehouses(updatedWarehouses);
          break;
          
        case 'box':
          if (!selectedWarehouse) throw new Error('No warehouse selected');
          const boxesData = csv.convertBoxCSV(csvData).map(box => ({
            ...box,
            uuid_warehouse: selectedWarehouse.id,
            is_rotated_box: box.is_rotated_box ? 1 : 0
          }));
          await api.createBoxesFromCSV(boxesData);
          const updatedBoxes = await api.fetchBoxesByWarehouse(selectedWarehouse.id);
          setBoxes(updatedBoxes);
          break;
      
        case 'section':
            if (!selectedWarehouse) throw new Error('No warehouse selected');
  
            const currentBoxes = await api.fetchBoxesByWarehouse(selectedWarehouse.id);
            const sectionsData = csv.convertSectionCSV(csvData);
            
            const sectionsWithIds = sectionsData.map(section => {
              // Если SKU пустое И количество равно 0, создаем секцию без привязки к коробке
              if ((!section.sku_name || section.sku_name.trim() === '') && (Number(section.count_box) === 0)) {
                return {
                  section_name: section.section_name,
                  sku_name: '', 
                  count_box: 0,
                  id_warehouse: selectedWarehouse.id,
                  id_box: '' 
                };
              }
              
              // Если SKU указано, но количество 0 - тоже допустимо
              if (Number(section.count_box) === 0) {
                const box = currentBoxes.find(b => b.sku_box === section.sku_name);
                return {
                  section_name: section.section_name,
                  sku_name: section.sku_name,
                  count_box: 0,
                  id_warehouse: selectedWarehouse.id,
                  id_box: box?.id || '' 
                };
              }
              
              const box = currentBoxes.find(b => b.sku_box === section.sku_name);
              if (!box) {
                throw new Error(`Коробка с SKU ${section.sku_name} не найдена на складе`);
              }
              
              return {
                section_name: section.section_name,
                sku_name: section.sku_name,
                count_box: Number(section.count_box) || 0,
                id_warehouse: selectedWarehouse.id,
                id_box: box.id
              };
            });
            
            await api.createSectionsFromCSV(sectionsWithIds);
            const updatedSections = await api.fetchSectionsByWarehouse(selectedWarehouse.id);
            setSections(updatedSections);
            break;
        default:
          throw new Error('Invalid type for CSV upload');
      }
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (type) => {
    setLoading(true);
    try {
      switch (type) {
        case 'warehouse':
          if (!selectedWarehouse) return;
          await api.deleteWarehouse(selectedWarehouse.id);
          setWarehouses(warehouses.filter(w => w.id !== selectedWarehouse.id));
          setSelectedWarehouse(null);
          setWarehouseForm({
            warehouse_name: '',
            warehouse_width: '',
            warehouse_length: ''
          });
          break;
          
        case 'box':
          if (!selectedBox) return;
          await api.deleteBox(selectedBox.id);
          setBoxes(boxes.filter(b => b.id !== selectedBox.id));
          setSelectedBox(null);
          setBoxForm({
            sku_box: '',
            width_box: '',
            length_box: '',
            height_box: '',
            weight_box: '',
            is_rotated_box: false,
            max_load_box: ''
          });
          break;
          
        case 'section':
          if (!selectedSection) return;
          await api.deleteSection(selectedSection.id);
          setSections(sections.filter(s => s.id !== selectedSection.id));
          setSelectedSection(null);
          setSectionForm({
            section_name: '',
            sku_name: '',
            count_box: ''
          });
          break;
          
        default:
          throw new Error('Invalid type for delete');
      }
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleRowDoubleClick = (type) => {
    switch (type) {
      case 'warehouse':
        setSelectedWarehouse(null);
        setWarehouseForm({
          warehouse_name: '',
          warehouse_width: '',
          warehouse_length: ''
        });
        break;
      case 'box':
        setSelectedBox(null);
        setBoxForm({
          sku_box: '',
          width_box: '',
          length_box: '',
          height_box: '',
          weight_box: '',
          is_rotated_box: false,
          max_load_box: ''
        });
        break;
      case 'section':
        setSelectedSection(null);
        setSectionForm({
          section_name: '',
          sku_name: '',
          count_box: ''
        });
        break;
      default:
        break;
    }
  };

  return (
    <div className="config-container">      
      <div className="warehouse-layout">
        <div className="warehouse-form">
          <h2>Редактирование склада</h2>
          <form onSubmit={handleWarehouseSubmit}>
            <div className="form-group">
              <label>Название склада</label>
              <input
                type="text"
                name="warehouse_name"
                value={warehouseForm.warehouse_name}
                onChange={handleWarehouseFormChange}
                required
              />
            </div>
            <div className="form-group">
              <label>Ширина (см)</label>
              <input
                type="number"
                name="warehouse_width"
                value={warehouseForm.warehouse_width}
                onChange={handleWarehouseFormChange}
                required
              />
            </div>
            <div className="form-group">
              <label>Длина (см)</label>
              <input
                type="number"
                name="warehouse_length"
                value={warehouseForm.warehouse_length}
                onChange={handleWarehouseFormChange}
                required
              />
            </div>
            <div className="form-actions">
              <button type="submit">{selectedWarehouse ? 'Обновить' : 'Добавить'}</button>
              {selectedWarehouse && (
                <button type="button" onClick={() => handleDelete('warehouse')}>Удалить</button>
              )}
               <label className="csv-upload">
                Загрузить склады из файла CSV(warehouse_id.csv)
                <input 
                  type="file" 
                  accept=".csv"
                  onChange={(e) => handleCSVUpload('warehouse', e.target.files[0])}
                  style={{ display: 'none' }}
                />
              </label>
            </div>
          </form>
        </div>

        <div className="warehouse-table">
          <h2>Список складов</h2>
          <table>
            <thead>
              <tr>
                <th>Название</th>
                <th>Ширина (см)</th>
                <th>Длина (см)</th>
              </tr>
            </thead>
            <tbody>
              {warehouses.map(warehouse => (
                <tr 
                  key={warehouse.id}
                  onClick={() => handleWarehouseSelect(warehouse)}
                  onDoubleClick={() => handleRowDoubleClick('warehouse')}
                  className={selectedWarehouse?.id === warehouse.id ? 'selected' : ''}
                >
                  <td>{warehouse.warehouse_name}</td>
                  <td>{warehouse.warehouse_width}</td>
                  <td>{warehouse.warehouse_length}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {error && <div className="error-message">{error}</div>}
      {loading && <div className="loading">Загрузка...</div>}

      {selectedWarehouse && (
        <div className="details-section">
          <div className="tabs">
            <button 
              className={activeTab === 'boxes' ? 'active' : ''}
              onClick={() => setActiveTab('boxes')}
            >
              Коробки на складе
            </button>
            <button 
              className={activeTab === 'sections' ? 'active' : ''}
              onClick={() => setActiveTab('sections')}
            >
              Секции на складе
            </button>
          </div>

          {activeTab === 'boxes' ? (
            <div className="box-layout">
              <div className="box-table">
                <h3>Список коробок</h3>
                <table>
                  <thead>
                    <tr>
                      <th>SKU</th>
                      <th>Ширина (см)</th>
                      <th>Длина (см)</th>
                      <th>Высота (см)</th>
                      <th>Вес (г)</th>
                      <th>Макс. нагрузка (г)</th>
                      <th>Поворот</th>
                    </tr>
                  </thead>
                  <tbody>
                    {boxes.map(box => (
                      <tr 
                        key={box.id}
                        onClick={() => handleBoxSelect(box)}
                        onDoubleClick={() => handleRowDoubleClick('box')}
                        className={selectedBox?.id === box.id ? 'selected' : ''}
                      >
                        <td>{box.sku_box}</td>
                        <td>{box.width_box}</td>
                        <td>{box.length_box}</td>
                        <td>{box.height_box}</td>
                        <td>{box.weight_box}</td>
                        <td>{box.max_load_box}</td>
                        <td>{box.is_rotated_box ? 'Да' : 'Нет'}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>

              <div className="box-form">
                <h3>{selectedBox ? 'Редактирование коробки' : 'Добавление коробки'}</h3>
                <form onSubmit={handleBoxSubmit}>
                  <div className="form-group">
                    <label>SKU (Код коробки)</label>
                    <input
                      type="text"
                      name="sku_box"
                      value={boxForm.sku_box}
                      onChange={handleBoxFormChange}
                      required
                    />
                  </div>
                  <div className="form-group">
                    <label>Ширина (см)</label>
                    <input
                      type="number"
                      name="width_box"
                      value={boxForm.width_box}
                      onChange={handleBoxFormChange}
                      required
                    />
                  </div>
                  <div className="form-group">
                    <label>Длина (см)</label>
                    <input
                      type="number"
                      name="length_box"
                      value={boxForm.length_box}
                      onChange={handleBoxFormChange}
                      required
                    />
                  </div>
                  <div className="form-group">
                    <label>Высота (см)</label>
                    <input
                      type="number"
                      name="height_box"
                      value={boxForm.height_box}
                      onChange={handleBoxFormChange}
                      required
                    />
                  </div>
                  <div className="form-group">
                    <label>Вес (г)</label>
                    <input
                      type="number"
                      name="weight_box"
                      value={boxForm.weight_box}
                      onChange={handleBoxFormChange}
                      required
                    />
                  </div>
                  <div className="form-group">
                    <label>Макс. нагрузка (г)</label>
                    <input
                      type="number"
                      name="max_load_box"
                      value={boxForm.max_load_box}
                      onChange={handleBoxFormChange}
                      required
                    />
                  </div>
                  <div className="form-group checkbox">
                    <label>
                      <input
                        type="checkbox"
                        name="is_rotated_box"
                        checked={boxForm.is_rotated_box}
                        onChange={handleBoxFormChange}
                      />
                      Разрешен поворот
                    </label>
                  </div>
                  <div className="form-actions">
                    <button type="submit">{selectedBox ? 'Обновить' : 'Добавить'}</button>
                    {selectedBox && (
                      <button type="button" onClick={() => handleDelete('box')}>Удалить</button>
                    )}
                     <label className="csv-upload">
                    Загрузить коробки из файла CSV(warehouse_sku.csv)
                      <input 
                        type="file" 
                        accept=".csv"
                        onChange={(e) => handleCSVUpload('box', e.target.files[0])}
                        style={{ display: 'none' }}
                      />
                    </label>
                  </div>
                </form>
              </div>
            </div>
          ) : (
            <div className="section-layout">
              <div className="section-table">
                <h3>Список секций</h3>
                <table>
                  <thead>
                    <tr>
                      <th>Название ячейки</th>
                      <th>SKU коробки</th>
                      <th>Количество</th>
                    </tr>
                  </thead>
                  <tbody>
                    {sections.map(section => (
                      <tr 
                        key={section.id}
                        onClick={() => handleSectionSelect(section)}
                        onDoubleClick={() => handleRowDoubleClick('section')}
                        className={selectedSection?.id === section.id ? 'selected' : ''}
                      >
                        <td>{section.section_name}</td>
                        <td>{section.sku_name}</td>
                        <td>{section.count_box}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>

              <div className="section-form">
                <h3>{selectedSection ? 'Редактирование секции' : 'Добавление секции'}</h3>
                <form onSubmit={handleSectionSubmit}>
                  <div className="form-group">
                    <label>Название ячейки</label>
                    <input
                      type="text"
                      name="section_name"
                      value={sectionForm.section_name}
                      onChange={handleSectionFormChange}
                      required
                    />
                  </div>
                  <div className="form-group">
                    <label>SKU коробки</label>
                    <select
                      name="sku_name"
                      value={sectionForm.sku_name}
                      onChange={handleSectionFormChange}
                      required
                    >
                      <option value="">Выберите коробку</option>
                      {boxes.map(box => (
                        <option key={box.id} value={box.sku_box}>
                          {box.sku_box}
                        </option>
                      ))}
                    </select>
                  </div>
                  <div className="form-group">
                    <label>Количество коробок</label>
                    <input
                      type="number"
                      name="count_box"
                      value={sectionForm.count_box}
                      onChange={handleSectionFormChange}
                      required
                    />
                  </div>
                  <div className="form-actions">
                    <button type="submit">{selectedSection ? 'Обновить' : 'Добавить'}</button>
                    {selectedSection && (
                      <button type="button" onClick={() => handleDelete('section')}>Удалить</button>
                    )}
                    <label className="csv-upload">
                    Загрузить секции из файла CSV(warehouse_section.csv)
                      <input 
                        type="file" 
                        accept=".csv"
                        onChange={(e) => handleCSVUpload('section', e.target.files[0])}
                        style={{ display: 'none' }}
                      />
                    </label>
                  </div>
                </form>
              </div>
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default WarehouseConfig;