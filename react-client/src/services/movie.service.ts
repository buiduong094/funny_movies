import axios from "axios";
import authHeader from './auth-header';
import { API_URL } from "../common/Constants";

class MovieService {
  create(url_share: string) {
    return axios
      .post(API_URL + "movies.json", {
        url_share
      }, { headers: authHeader() })
      .then(response => {
        return response.data;
      });
  }

  like(id: string, action_type:string) {
    return axios
      .post(API_URL + "movies/like", {
        id,action_type
      }, { headers: authHeader() })
      .then(response => {
        return response.data;
      });
  }
}

export default new MovieService();
