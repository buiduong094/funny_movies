import { Component } from "react";
import {useState} from 'react';
import UserService from "../services/user.service";

type Props = {};

type State = {
  content: string;
  movies: Array<any>;
}

export default class Home extends Component<Props, State> {
  constructor(props: Props) {
    super(props);

    this.state = {
      content: "",
      movies: []
    };
  }


  componentDidMount() {
    UserService.getPublicContent().then(
      response => {
        console.log(response.data)
        this.setState({
          movies: response.data
        });
      },
      error => {
        this.setState({
          content:
            (error.response && error.response.data) ||
            error.message ||
            error.toString()
        });
      }
    );
  }

  render() {
    const {movies} = this.state;
    return (
      <div className="container">
        <header className="jumbotron">
          <div className="list-group videos">
            {movies &&
              movies.map((movie, index) => (
                <div className="row" key={index}>
                  <div className="video video-container col-md-6">
                    <iframe
                      width="100%"
                      height="100%"
                      src={`https://www.youtube.com/embed/${movie.youtube_id}`}
                      frameBorder="0"
                      allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                      allowFullScreen
                      title="Embedded youtube"
                    />
                  </div>
                  <div className="col-md-6">
                    <label className="text-danger font-weight-bold">{movie.title}</label>
                    <label>Share by: {movie.user_email}</label>
                    <label>Description:</label>
                    <p className="video-description">{movie.description}</p>
                  </div>
                </div>
              ))}
          </div>
        </header>
      </div>
    );
  }
}
