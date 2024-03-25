import { Component } from "react";
import { Routes, Route, Link } from "react-router-dom";
import "bootstrap/dist/css/bootstrap.min.css";
import "./App.css";

import AuthService from "./services/auth.service";
import IUser from './types/user.type';

import Login from "./components/login.component";
import Register from "./components/register.component";
import Home from "./components/home.component";
import Share from "./components/share.component";
import BoardUser from "./components/board-user.component";
import BoardModerator from "./components/board-moderator.component";
import BoardAdmin from "./components/board-admin.component";

import EventBus from "./common/EventBus";

type Props = {};

type State = {
  showModeratorBoard: boolean,
  showAdminBoard: boolean,
  currentUser: IUser | undefined,
  showMessage: boolean,
  showMessagerAlert: string
}

class App extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.logOut = this.logOut.bind(this);

    this.state = {
      showModeratorBoard: false,
      showAdminBoard: false,
      currentUser: undefined,
      showMessage: false,
      showMessagerAlert: ''
    };
  }

  componentDidMount() {
    const user = AuthService.getCurrentUser();
    const uuid = Math.random().toString().substring(2,15);
    if (user) {
      this.setState({
        currentUser: user,
        showModeratorBoard: user.roles.includes("ROLE_MODERATOR"),
        showAdminBoard: user.roles.includes("ROLE_ADMIN"),
      });
      const ws = new WebSocket("ws://localhost:8000/cable");
      ws.onopen = () => {
        ws.send(
          JSON.stringify({
            command: 'subscribe',
            identifier: JSON.stringify({
              id: uuid,
              channel: "NotificationChannel"
            })
          })
        )
      };
      ws.onmessage = (e) => {
        const data = JSON.parse(e.data);
        if (data.type === "ping") return;
        if (data.type === "welcome") return;
        if (data.type === "confirm_subscription") return;
        if(user.username === data.message.username) return;
        this.setState({
          showMessage: true,
          showMessagerAlert: `${data.message.username} share ${data.message.title}`
        });
        const timeId = setTimeout(() => {
          // After 3 seconds set the show value to false
          this.setState({
            showMessage: false
          });
        }, 10000);
        return () => {
          clearTimeout(timeId)
        }
      }
    }

    EventBus.on("logout", this.logOut);
  }

  componentWillUnmount() {
    EventBus.remove("logout", this.logOut);
  }

  logOut() {
    AuthService.logout();
    this.setState({
      showModeratorBoard: false,
      showAdminBoard: false,
      currentUser: undefined,
    });
  }

  render() {
    const { currentUser, showMessage, showMessagerAlert} = this.state;

    return (
      <div>
        <nav className="navbar navbar-expand navbar-dark bg-dark">
          <Link to={"/"} className="navbar-brand">
            Funny Movies
          </Link>
          <div className="navbar-nav mr-auto">
{/*             <li className="nav-item">
              <Link to={"/home"} className="nav-link">
                Home
              </Link>
            </li>

            {showModeratorBoard && (
              <li className="nav-item">
                <Link to={"/mod"} className="nav-link">
                  Moderator Board
                </Link>
              </li>
            )}

            {showAdminBoard && (
              <li className="nav-item">
                <Link to={"/admin"} className="nav-link">
                  Admin Board
                </Link>
              </li>
            )}

            {currentUser && (
              <li className="nav-item">
                <Link to={"/user"} className="nav-link">
                  User
                </Link>
              </li>
            )} */}
          </div>

          {currentUser ? (
            <div className="navbar-nav ml-auto">
            <li className="nav-item">
              <a href="#" className="nav-link nav-userinfor" >
                Wellcome {currentUser.email}
              </a>
            </li>
              <li className="nav-item">
                <Link to={"/share"} className="nav-link">
                  Share a movie
                </Link>
              </li>
              <li className="nav-item">
                <a href="/login" className="nav-link" onClick={this.logOut}>
                  LogOut
                </a>
              </li>
            </div>
          ) : (
            <div className="navbar-nav ml-auto">
              <li className="nav-item">
                <Link to={"/login"} className="nav-link">
                  Login
                </Link>
              </li>

              <li className="nav-item">
                <Link to={"/register"} className="nav-link">
                  Sign Up
                </Link>
              </li>
            </div>
          )}
        </nav>
        {showMessage ? (
        <div className={`alert alert-info`}>
          {showMessagerAlert}
        </div>
          ): ( <div></div>)}
        <div className="container mt-3">
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/home" element={<Home />} />
            <Route path="/login" element={<Login />} />
            <Route path="/register" element={<Register />} />
            <Route path="/share" element={<Share />} />
            <Route path="/user" element={<BoardUser />} />
            <Route path="/mod" element={<BoardModerator />} />
            <Route path="/admin" element={<BoardAdmin />} />
          </Routes>
        </div>

        { /*<AuthVerify logOut={this.logOut}/> */}
      </div>
    );
  }
}

export default App;