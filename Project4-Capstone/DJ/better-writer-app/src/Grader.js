import React, { Component } from 'react';

export default class Grader extends Component{
  
  constructor(props){
    super(props)
  }

  render(){
    const { analysisKeys, analysis } = this.props;

    //not checking for nested objects
    let data = analysisKeys.map( (item, i ) => {
      if(typeof(analysis[item]) !== 'object'){
        return <li key={i}>{item} = {analysis[item]}</li>
      }
    })

    return(
      <div>
      {data}
      </div>
    )
  }
}