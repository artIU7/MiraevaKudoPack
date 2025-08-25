import React from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import './Sidebar.css';
import kudoLogo from './kudo.png';

const Sidebar = ({ setActiveMenuItem }) => {
  const location = useLocation();
  const navigate = useNavigate();

  // Цвет кнопок меню и панели сверху над страницей как в Qt клиенте 
  const menuItems = [
    { 
      path: '/dashboard/warehouse-config',
      title: 'Конфигурация склада',
      bgColor: '#A5D0ED'
    },
    { 
      path: '/dashboard/warehouse-orders',
      title: 'Формирование заказов',
      bgColor: '#A1D0C4'
    },
    { 
      path: '/dashboard/warehouse-state',
      title: 'Мониторинг склада',
      bgColor: '#BFC6CA'
    },
    { 
      path: '/dashboard/warehouse-map',
      title: 'Карта склада',
      bgColor: '#C4A8C3'
    },
    { 
      path: '/dashboard/warehouse-users',
      title: 'Пользователи',
      bgColor: '#B5CE8F'
    }
  ];

  const handleMenuItemClick = (title, bgColor) => {
    setActiveMenuItem({ title, bgColor });
  };

  const handleLogout = () => {
    localStorage.removeItem('user');    
    window.dispatchEvent(new Event('storage'));    
    navigate('/', { replace: true });
  };

  return (
    <div className="sidebar">
      <div className="sidebar-header">
        <img src={kudoLogo} alt="Kudo Logo" className="kudo-logo" />
      </div>
      <ul className="sidebar-menu">
        {menuItems.map((item) => (
          <li 
            key={item.path}
            className={location.pathname === item.path ? 'active' : ''}
            onClick={() => handleMenuItemClick(item.title, item.bgColor)}
          >
            <Link to={item.path}>{item.title}</Link>
          </li>
        ))}
      </ul>
      <div className="logout-container">
        <button 
          className="logout-button"
          onClick={handleLogout}
        >
          Выйти
        </button>
      </div>
    </div>
  );
};

export default Sidebar;