import { Component } from "react";
import UserService from "../services/user.service";
import MovieService from "../services/movie.service";

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
        this.setState({
          // movies: response.data // use ruby response
          movies: response.data.results // use nestjs response
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

  like(formValue: { id: string; action_type: string}) {
    const { id, action_type } = formValue;
    let {movies} = this.state;

    MovieService.like(
      id,action_type
    ).then(
      response => {
        movies = movies.map(movie => movie.id === response.id ? response : movie);
        this.setState({movies: [...movies]});
      },
      error => {
        // const resMessage =
        //   (error.response &&
        //     error.response.data &&
        //     error.response.data.message) ||
        //   error.message ||
        //   error.toString();

        // this.setState({
        //   // successful: false,
        //   // submitted: true,
        //   // message: resMessage
        // });
      }
    );
  };
  render() {
    const {movies} = this.state;
    return (
      <div className="container">
        <header className="">
          <div className="list-group videos">
            {movies &&
              movies?.map((movie, index) => (
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
                    {/* {movie.like_action =="like" ? <button onClick={(e)=> this.like({id: movie.id, action_type: 'unlike'})}>unlike</button> : <div></div>}
                    {movie.like_action =="none" ? <button onClick={(e)=> this.like({id: movie.id, action_type: 'like'})}>like</button> : <div></div>}
                    {movie.like_action =="dislike" ? <button onClick={(e)=> this.like({id: movie.id, action_type: 'undislike'})}>undislike</button> : <div></div>}
                    {movie.like_action =="none" ? <button onClick={(e)=> this.like({id: movie.id, action_type: 'dislike'})}>dislike</button> : <div></div>} */}
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
