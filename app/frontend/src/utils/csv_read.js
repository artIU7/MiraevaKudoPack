export const readCSV = (file) => {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = (event) => {
        const csvData = event.target.result;
        const lines = csvData.split('\n');
        const headers = lines[0].split(',');
        const result = [];
  
        for (let i = 1; i < lines.length; i++) {
          if (!lines[i]) continue;
          const obj = {};
          const currentline = lines[i].split(',');
  
          for (let j = 0; j < headers.length; j++) {
            obj[headers[j].trim()] = currentline[j] ? currentline[j].trim() : '';
          }
          result.push(obj);
        }
        resolve(result);
      };
      reader.onerror = (error) => reject(error);
      reader.readAsText(file);
    });
  };
  
  export const convertSectionGeometryCSV = (csvData, warehouseId) => {
    return csvData.map(item => ({
      id_warehouse: warehouseId,
      name_section: item['Название секции'],
      x_pos: parseInt(item['Позиция X']),
      y_pos: parseInt(item['Позиция Y']),
      widht_wsec: parseInt(item['Ширина (см.)']),
      lenght_wsec: parseInt(item['Длина (см.)']),
      name_point_way: item['Точка графа']
    }));
  };
  
  export const convertPointsCSV = (csvData, warehouseId) => {
    return csvData.map(item => ({
      id_warehouse: warehouseId,
      name_points: item['Название точки'],
      pos_x: parseInt(item['Позиция X']),
      pos_y: parseInt(item['Позиция Y'])
    }));
  };
  
  export const convertEdgesCSV = (csvData, warehouseId, points) => {
    return csvData.map(item => {      
      return {
        id_warehouse: warehouseId,
        name_points_from: item['Точка 1(Начало ребра)'],
        name_points_to: item['Точка 2(Конец ребра)']
      };
    });
  };

  export const convertWarehouseCSV = (csvData) => {
    return csvData.map(item => ({
      warehouse_name: item['Название склада'],
      warehouse_width: parseInt(item['Ширина (см.)']),
      warehouse_length: parseInt(item['Длина (см.)'])
    }));
  };

  export const convertBoxCSV = (csvData) => {
    return csvData.map(item => ({
      sku_box: item['SKU'],
      width_box: parseInt(item['Ширина (см.)']),
      length_box: parseInt(item['Длина (см.)']),
      height_box: parseInt(item['Высота (см.)']),
      weight_box: parseInt(item['Вес (г.)']),
      is_rotated_box: item['Можно вращать'] === 'True',
      max_load_box: parseInt(item['Макс. нагрузка (г.)'])
    }));
  };
  
  export const convertSectionCSV = (csvData) => {
    return csvData.map(item => ({
      section_name: item['Ячейка'],
      sku_name: item['SKU'],
      count_box: parseInt(item['Количество'])
    }));
  };