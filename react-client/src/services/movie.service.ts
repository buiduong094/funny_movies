import axios from "axios";
import authHeader from './auth-header';

const API_URL = 'http://localhost:8000/';


class MovieService {
  create(url_share: string) {
    return axios
      .post(API_URL + "movies.json", {
        url_share
      }, { headers: authHeader() })
      .then(response => {
        console.log('create response',response)
        return response.data;
      });
  }

}

export default new MovieService();
