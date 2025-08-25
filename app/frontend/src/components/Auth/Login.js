import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  login,
} from '../../utils/api';
import './Login.css';
import kudoLogo from './kudo.png'; 

const Login = () => {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    
    try {
      const userData = await login(username, password);
      
      if (!userData?.id) {
        throw new Error('Неверный формат ответа сервера');
      }

      if (userData.warehouseId) {
        localStorage.setItem('user', JSON.stringify(userData));
      } else {
        localStorage.setItem('user', JSON.stringify(userData));
      }

      window.dispatchEvent(new Event('storage'));
      navigate('/dashboard/', { replace: true });
    } catch (err) {
      setError(err.response?.data?.message || 'Ошибка авторизации');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="login-container">
      <div className="login-box">
        <img src={kudoLogo} alt="Kudo Logo" className="logo" />
        
        <form onSubmit={handleSubmit} className="login-form">
          <div className="input-field">
            <input
              type="text"
              placeholder="Логин"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              required
            />
          </div>
          
          <div className="input-field">
            <input
              type="password"
              placeholder="Пароль"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>
          
          {error && <div className="error-message">{error}</div>}
          
          <button type="submit" className="login-button" disabled={isLoading}>
            {isLoading ? 'Загрузка...' : 'Войти'}
          </button>
        </form>
      </div>
    </div>
  );
};

export default Login;