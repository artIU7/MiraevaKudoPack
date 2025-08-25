import React, { useState, useEffect } from 'react';
import { Outlet, useLocation } from 'react-router-dom';
import Sidebar from './Sidebar';
import './DashboardLayout.css';

const DashboardLayout = () => {
  const user = JSON.parse(localStorage.getItem('user'));
  const location = useLocation();
  const [activeMenuItem, setActiveMenuItem] = useState({
    title: `Добро пожаловать, ${user?.user_fio}`,
    bgColor: '#A5D0ED' 
  });

  // Автоматически устанавливаем цвет и заголовок при первом рендере как в Qt клиенте
  useEffect(() => {
    const menuItems = [
      { path: '/dashboard/warehouse-config', title: 'Конфигурация склада', bgColor: '#A5D0ED' },
      { path: '/dashboard/warehouse-orders', title: 'Формирование заказов', bgColor: '#A1D0C4' },
      { path: '/dashboard/warehouse-state', title: 'Мониторинг склада', bgColor: '#BFC6CA' },
      { path: '/dashboard/warehouse-map', title: 'Карта склада', bgColor: '#C4A8C3' },
      { path: '/dashboard/warehouse-users', title: 'Пользователи', bgColor: '#B5CE8F' }
    ];

    const currentItem = menuItems.find(item => location.pathname === item.path);
    if (currentItem) {
      setActiveMenuItem({
        title: currentItem.title,
        bgColor: currentItem.bgColor
      });
    }
  }, [location.pathname]);

  return (
    <div className="dashboard-layout">
      <Sidebar setActiveMenuItem={setActiveMenuItem} />
      <div className="main-content">
        <div 
          className="header"
          style={{ backgroundColor: activeMenuItem.bgColor }}
        >
          <h2>{activeMenuItem.title}</h2>
        </div>
        <div className="content">
          <Outlet />
        </div>
      </div>
    </div>
  );
};

export default DashboardLayout;