import React, { Component } from "react";
import EducationPlatformContract from "./contracts/EducationPlatform.json";
import getWeb3 from "./getWeb3";

import "./App.css";

class App extends Component {
  state = { name: '', description: '', website: '', phone: '', uniId: 0, web3: null, accounts: null, contract: null };

handleChange(event)
{
    switch(event.target.name) {
        case "bountyData":
            this.setState({"bountyData": event.target.value})
            break;
        case "bountyDeadline":
            this.setState({"bountyDeadline": event.target.value})
            break;
        case "bountyAmount":
            this.setState({"bountyAmount": event.target.value})
            break;
        default:
            break;
    }
}

  websiteChangeHandler = (event) => {
    this.setState({website: event.target.value});
  }
  nameChangeHandler = (event) => {
    this.setState({name: event.target.value});
  }
  descriptionChangeHandler = (event) => {
    this.setState({description: event.target.value});
  }
  phoneChangeHandler = (event) => {
    this.setState({phone: event.target.value});
  }

  UniIDChangeHandler = (event) => {
    this.setState({uniId: event.target.value});
  }

  getUniversityHandler = async () => {
    console.log('Get University was clicked - uniID = ' + this.state.uniId);

    const { contract } = this.state;
    
    // Get the value from the contract to prove it worked.
    const response = await contract.methods.getUniversity(this.state.uniId).call();    

    // Update state with the result.
    this.setState({ name: response.name });
    this.setState({ description: response.description });
    this.setState({ website: response.website });
    this.setState({ phone: response.phone });

    console.log(contract);
    console.log("----------------");
    console.log(this.state.name);
    console.log(this.state.website);
    console.log(this.state.description);    
   }
  addUniversityHandler = async () => {
    console.log('button was clicked');   
    //console.log(this.state.website);
    try
    {
      this.runExample();
    }  catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`,
      );
      console.error(error);
    }
  }

  componentDidMount = async () => {
    try {
      // Get network provider and web3 instance.
      const web3 = await getWeb3();

      // Use web3 to get the user's accounts.
      const accounts = await web3.eth.getAccounts();

      // Get the contract instance.
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = EducationPlatformContract.networks[networkId];
      const instance = new web3.eth.Contract(
        EducationPlatformContract.abi,
        deployedNetwork && deployedNetwork.address,
      );

      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.setState({ web3, accounts, contract: instance }); //, this.runExample);
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`,
      );
      console.error(error);
    }
  };

  runExample = async () => {
    const { accounts, contract } = this.state;

    // Stores a given value, 5 by default.
    //await contract.methods.set(5).send({ from: accounts[0] });
    await contract.methods.addUniversity(this.state.name, this.state.description, this.state.website, this.state.phone).send({ from: accounts[0] });
    //await contract.methods.addUniversity('Uni0','This is Uni0', 'www.uni0.com', '88793949').send({ from: accounts[0] });

    const web3 = await getWeb3();
    let newUniSubscription = web3.eth.subscribe('LogUniversityAdded', {}, 
      function(error, result){
      if (!error)
          console.log(result);
      }
    );

    let uniAdded = this.state.contract.addUniversity;
    uniAdded.watch((err, response) => {
      if (err) { console.log("could not get event" + err)}
      else {console.log("watching the event worked!!! " + response)}
    });
    
    // Get the value from the contract to prove it worked.
    const response = await contract.methods.getUniversity(1).call();

    // Update state with the result.
    this.setState({ name: response.name });
    this.setState({ description: response.description });
    this.setState({ website: response.website });
  };

  render() {
    if (!this.state.web3) {
      return <div>Loading Web3, accounts, and contract...</div>;
    }
    return (
      <div className="App">
        <h1>Educational Platform</h1>        
        <h2>Smart Contract Example</h2>
        <hr />
        <h3>Add University</h3>        
        <p>Name: <input type="text" onChange={this.nameChangeHandler} /> </p>
        <p>Description: <input type="text" onChange={this.descriptionChangeHandler} /> </p>
        <p>Website: <input type="text" onChange={this.websiteChangeHandler} /> </p>
        <p>Phone Number: <input type="text" onChange={this.phoneChangeHandler} /> </p>
        <button onClick={this.addUniversityHandler}>Add University</button>
        <hr/>
        <h3>Read University</h3>
        <p>University ID: <input type="text" onChange={this.UniIDChangeHandler} />
          <button onClick={this.getUniversityHandler}>Get University</button></p>
        <p>Name: <input type="text" value={this.name} /> </p>
        <p>Description: <input type="text" value={this.description} /> </p>
        <p>Website: <input type="text" onChange={this.website} /> </p>
        <p>Phone Number: <input type="text" onChange={this.phone} /> </p>
        <hr />
        <div>The stored name value is: {this.state.name}</div>

      </div>
    );
  }
}

export default App;
