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
          <h3>{this.state.content}</h3>

          <ul className="list-group">
            {movies &&
              movies.map((movie, index) => (
                <li
                  key={index}
                >
                  {/* <iframe
                    width="353"
                    height="280"
                    src={`https://www.youtube.com/embed/6pgIqCv8gGU`}
                    frameBorder="0"
                    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                    allowFullScreen
                    title="Embedded youtube"
                  />  */}
                  <label>{movie.title}</label>
                  <label>Share by: {movie.user_email}</label>
                  <label>Description:</label>
                  {/* <p>{movie.description}</p> */}

                </li>
                
              ))}
          </ul>
          <div className="video-responsive">
          </div>
        </header>
      </div>
    );
  }
}
