import axios from 'axios';
import authHeader from './auth-header';
import { API_URL } from '../common/Constants';

class UserService {
  getPublicContent() {
    return axios.get(API_URL + 'movies.json', { headers: authHeader() });
    // return axios.get(API_URL + 'all');
  }

  getUserBoard() {
    return axios.get(API_URL + 'user', { headers: authHeader() });
  }

  getModeratorBoard() {
    return axios.get(API_URL + 'mod', { headers: authHeader() });
  }

  getAdminBoard() {
    return axios.get(API_URL + 'admin', { headers: authHeader() });
  }
}

export default new UserService();
