import axios from "axios";
import { API_URL } from "../common/Constants";

class AuthService {

  login(username: string, password: string) {
    const remember = true;
    return axios
      .post(API_URL + "auth/login", {
        username,
        password,
        remember
      })
      .then(response => {
        if (response.data.accessToken) {
          localStorage.setItem("user", JSON.stringify(response.data));
        }
        return response.data;
      }, error => {
        return error;
      });
  }

  logout() {
    localStorage.removeItem("user");
  }

  register(username: string, email: string, password: string) {
    return axios.post(API_URL + "signup", {
      username,
      email,
      password
    });
  }

  getCurrentUser() {
    const userStr = localStorage.getItem("user");
    if (userStr) return JSON.parse(userStr);

    return null;
  }
}

export default new AuthService();
