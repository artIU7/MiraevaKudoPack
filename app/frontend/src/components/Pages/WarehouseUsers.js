import React, { useEffect, useState } from 'react';
import './WarehouseUsers.css';
import * as api from '../../utils/api';

const WarehouseUsers = () => {
  const [warehouses, setWarehouses] = useState([]);
  const [selectedWarehouse, setSelectedWarehouse] = useState(null);
  const [users, setUsers] = useState([]);
  const [error, setError] = useState(null);

  const [selectedUser, setSelectedUser] = useState(null);

  const [userForm, setUserForm] = useState({
    user_fio: '',
    user_login: '',
    user_password: '',
    is_manager: false,
    is_employee: false
  });

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
      setUsers([]);
      return;
    }
    
    const loadUsers = async () => {
      try {
        const usersData = await api.fetchUsersByWarehouse(selectedWarehouse.id);
        setUsers(usersData);
      } catch (error) {
        setError('Ошибка загрузки пользователей склада');
      }
    };
    
    loadUsers();
  }, [selectedWarehouse]);

  const handleWarehouseSelect = (warehouse) => {
    setSelectedWarehouse(warehouse);
    setSelectedUser(null);
    setUserForm({
      user_fio: '',
      user_login: '',
      user_password: '',
      is_manager: false,
      is_employee: false
    });
  };

  const handleWarehouseDeselect = () => {
    setSelectedWarehouse(null);
  };

  const handleUserSelect = (user) => {
    setSelectedUser(user);
    setUserForm({
      user_fio: user.user_fio,
      user_login: user.user_login,
      user_password: user.user_password,
      is_manager: user.user_role === 2,
      is_employee: user.user_role === 1
    });
  };

  const handleUserDeselect = () => {
    setSelectedUser(null);
    setUserForm({
      user_fio: '',
      user_login: '',
      user_password: '',
      is_manager: false,
      is_employee: false
    });
  };

  const handleUserFormChange = (e) => {
    const { name, value, type, checked } = e.target;
    
    if (type === 'checkbox') {
      if (name === 'is_manager') {
        setUserForm(prev => ({
          ...prev,
          is_manager: checked,
          is_employee: !checked
        }));
      } else if (name === 'is_employee') {
        setUserForm(prev => ({
          ...prev,
          is_employee: checked,
          is_manager: !checked
        }));
      }
    } else {
      setUserForm(prev => ({ ...prev, [name]: value }));
    }
  };

  const handleAddUser = async () => {
    if (!selectedWarehouse) return;
    try {
      const newUser = await api.createUser({
        ...userForm,
        user_role: userForm.is_manager ? 2 : 1,
        uuid_warehouse: selectedWarehouse.id
      });
      setUsers(prev => [...prev, newUser]);
      setUserForm({
        user_fio: '',
        user_login: '',
        user_password: '',
        is_manager: false,
        is_employee: false
      });
    } catch (error) {
      setError('Ошибка добавления пользователя');
      console.error('Error adding user:', error);
    }
  };

  const handleUpdateUser = async () => {
    if (!selectedUser) return;
    try {
      const updatedUser = await api.updateUser(selectedUser.id, {
        ...userForm,
        user_role: userForm.is_manager ? 2 : 1,
        uuid_warehouse: selectedWarehouse.id
      });
      setUsers(prev => prev.map(u => 
        u.id === selectedUser.id ? updatedUser : u
      ));
    } catch (error) {
      setError('Ошибка обновления пользователя');
      console.error('Error updating user:', error);
    }
  };

  const handleDeleteUser = async () => {
    if (!selectedUser) return;
    try {
      await api.deleteUser(selectedUser.id);
      setUsers(prev => prev.filter(u => u.id !== selectedUser.id));
      handleUserDeselect();
    } catch (error) {
      setError('Ошибка удаления пользователя');
      console.error('Error deleting user:', error);
    }
  };

  return (
    <div className="users-container">
      {error && (
        <div className="error-message" onClick={() => setError(null)}>
          {error}
        </div>
      )}

      <div className="warehouse-users-content">
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

        <div className="users-table-container">
          <table className="users-table">
            <thead>
              <tr>
                <th>ФИО</th>
                <th>Логин</th>
                <th>Роль</th>
              </tr>
            </thead>
            <tbody>
              {users.map(user => (
                <tr 
                  key={user.id}
                  onClick={() => handleUserSelect(user)}
                  onDoubleClick={handleUserDeselect}
                  className={selectedUser?.id === user.id ? 'selected' : ''}
                >
                  <td>{user.user_fio}</td>
                  <td>{user.user_login}</td>
                  <td>{user.user_role === 2 ? 'Начальник склада' : 'Сотрудник'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <div className="user-edit-form">
  <h4>{selectedUser ? 'Редактировать пользователя' : 'Добавить пользователя'}</h4>
  <div className="form-group">
    <label>ФИО пользователя</label>
    <input
      type="text"
      name="user_fio"
      value={userForm.user_fio}
      onChange={handleUserFormChange}
    />
  </div>
  <div className="form-group">
    <label>Логин</label>
    <input
      type="text"
      name="user_login"
      value={userForm.user_login}
      onChange={handleUserFormChange}
    />
  </div>
  <div className="form-group">
    <label>Пароль</label>
    <input
      type="password"
      name="user_password"
      value={userForm.user_password}
      onChange={handleUserFormChange}
    />
  </div>
  <div className="form-group">
    <label>Роль:</label>
    <div className="role-checkboxes">
      <label className="checkbox-label">
        Начальник {'  '}
        <input
          type="checkbox"
          name="is_manager"
          checked={userForm.is_manager}
          onChange={handleUserFormChange}
        />
      </label>
      <label className="checkbox-label">
        Сотрудник {'  '}
        <input
          type="checkbox"
          name="is_employee"
          checked={userForm.is_employee}
          onChange={handleUserFormChange}
        />
      </label>
    </div>
  </div>
  <div className="form-actions">
    {!selectedUser ? (
      <button onClick={handleAddUser}>Добавить</button>
    ) : (
      <>
        <button onClick={handleUpdateUser}>Обновить</button>
        <button onClick={handleDeleteUser}>Удалить</button>
      </>
    )}
  </div>
</div>
      </div>
    </div>
  );
};

export default WarehouseUsers;