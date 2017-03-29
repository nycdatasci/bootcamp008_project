import React from 'react'

var CountdownTimer = React.createClass({
  getInitialState: function() {
    return {
      seconds: 0
    };
  },
  tick: function() {
    this.setState({seconds: this.state.seconds + 1});
  },
  componentDidMount: function() {
    this.interval = setInterval(this.tick, 1000);
  },
  componentWillUnmount: function() {
    clearInterval(this.interval);
  },
  render: function() {

    const minutes = Math.floor(this.state.seconds / 60)
    var seconds = this.state.seconds % 60
    if(seconds < 10){
      seconds = '0' + seconds
    } 

    return (
      <div>Time Elapsed: {minutes}:{seconds}</div>
    );
  }
});

export default CountdownTimer