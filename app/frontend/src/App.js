import { Routes, Route, Navigate } from 'react-router-dom';
import Login from './components/Auth/Login';
import DashboardLayout from './components/Layout/DashboardLayout';
import WarehouseOrders from './components/Pages/WarehouseOrders';
import WarehouseMap from './components/Pages/WarehouseMap';
import WarehouseConfig from './components/Pages/WarehouseConfig';
import WarehouseState from './components/Pages/WarehouseState';
import WarehouseUsers from './components/Pages/WarehouseUsers';
import './App.css';
import React, { useEffect, useState } from 'react';

const App = () => {
  const [isAuthenticated, setIsAuthenticated] = useState(
    () => !!localStorage.getItem('user')
  );

   useEffect(() => {
    const handleStorageChange = () => {
      const auth = !!localStorage.getItem('user');
      setIsAuthenticated(auth);
      
      if (!auth && window.location.pathname !== '/') {
        window.location.href = '/';
      }
    };

    window.addEventListener('storage', handleStorageChange);
    return () => window.removeEventListener('storage', handleStorageChange);
  }, []);

  return (
    <div className="App">
      <Routes>
        <Route path="/" element={isAuthenticated ? <Navigate to="/dashboard/warehouse-config" /> : <Login />} />
        <Route path="/dashboard" element={isAuthenticated ? <DashboardLayout /> : <Navigate to="/" />}>
          <Route path="warehouse-config" element={<WarehouseConfig />} />  
          <Route path="warehouse-orders" element={<WarehouseOrders />} />
          <Route path="warehouse-state" element={<WarehouseState />} />
          <Route path="warehouse-map" element={<WarehouseMap />} />
          <Route path="warehouse-users" element={<WarehouseUsers />} />
          <Route index element={<Navigate to="warehouse-config" />} />
        </Route>
      </Routes>
    </div>
  );
};

export default App;