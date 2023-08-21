import { Component } from "react";
import { Navigate } from "react-router-dom";
import AuthService from "../services/auth.service";
import MovieService from "../services/movie.service";
import IUser from "../types/user.type";
import * as Yup from "yup";
import { Formik, Field, Form, ErrorMessage } from "formik";

type Props = {};

type State = {
  redirect: string | null,
  userReady: boolean,
  currentUser: IUser & { accessToken: string },
  submitted: boolean,
  successful: boolean,
  message: string
}
export default class Share extends Component<Props, State> {
  constructor(props: Props) {
    super(props);

    this.shareMovie = this.shareMovie.bind(this);
    
    this.state = {
      redirect: null,
      userReady: false,
      currentUser: { accessToken: "" },
      submitted: false,
      successful: false,
      message: ''
    };
  }

  componentDidMount() {
    const currentUser = AuthService.getCurrentUser();

    if (!currentUser) this.setState({ redirect: "/home" });
    this.setState({ currentUser: currentUser, userReady: true })
  }

  newShare = () => {
    this.setState({successful: false});
  };

  shareMovie(formValue: { url: string; }) {
    const { url } = formValue;
    this.setState({
      successful: false
    });

    MovieService.create(
      url
    ).then(
      response => {
        this.setState({submitted: true,successful: true});
      },
      error => {
        const resMessage =
          (error.response &&
            error.response.data &&
            error.response.data.message) ||
          error.message ||
          error.toString();

        this.setState({
          successful: false,
          submitted: true,
          message: resMessage
        });
      }
    );
  };

  validationSchema() {
    return Yup.object().shape({
      url: Yup.string()
        .test(
          "len",
          "The url must be between 10 and 200 characters.",
          (val: any) =>
            val &&
            val.toString().length >= 10 &&
            val.toString().length <= 200
        )
        .required("This field is required!"),
    });
  }
  render() {

    const initialValues = {
      url: "",
    };
    if (this.state.redirect) {
      return <Navigate to={this.state.redirect} />
    }

    const { message, successful} = this.state;

    return (
      <div className="container">
        {(this.state.userReady) ?
          <div>
            <header className="jumbotron">
              <h5>
                Share a Youtube movie
              </h5>
            </header>
            <div className="submit-form">
      {successful ? (
        <div>
          <h4>You submitted successfully!</h4>
          <button className="btn btn-success" onClick={this.newShare}>
            Share a new movie
          </button>
        </div>
      ) : (

        <Formik
          initialValues={initialValues}
          validationSchema={this.validationSchema}
          onSubmit={this.shareMovie}
        >
          <Form>
            <div className="form-group">
              <label htmlFor="url"> Youtube URL: </label>
              <Field name="url" type="text" className="form-control" />
              <ErrorMessage
                name="url"
                component="div"
                className="alert alert-danger"
              />
            </div>
            {message && (
              <div className="form-group">
                <div
                  className={
                    successful ? "alert alert-success" : "alert alert-danger"
                  }
                  role="alert"
                >
                  {message}
                </div>
              </div>
            )}
            <div>
              <button type="submit"  className="btn btn-success">Share</button>
            </div>
          </Form>
        </Formik>
      )}
    </div>
          </div> : null}
      </div>
    );
  }
}
