import React, { Component } from 'react';
import {
  BrowserRouter as Router,
  Route,
  Link,
  Switch
} from 'react-router-dom'

import PlainText from './PlainText.js'

export default class App extends Component{
  
  constructor(props){
    super(props)
  }

  render(){
    return(
      <Router>
        <div>
          <ul>
            <li><Link to="/">Pick An Essay Topic</Link></li>
          </ul>

          <hr/>
          <Switch>
            <Route exact path="/" component={PickAnEssay}/>
            <Route exact path="/:essay" 
              render={props => {
                const essay = props.match.url.replace('/', '')
                return <PlainText essay={essay}/>
              }
            }/>
          </Switch>
        </div>
      </Router>
    )
  }
}

const PickAnEssay = () => (
  <div>
    <h1>PickAnEssay</h1>
     <li><Link to="/essay1">Essay 1</Link></li>
     <li><Link to="/essay2">Essay 2</Link></li>
     <li><Link to="/essay3">Essay 3</Link></li>
  </div>
)