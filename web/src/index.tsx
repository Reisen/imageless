import React                            from 'react';
import thunk                            from 'redux-thunk';
import { HashRouter as Router, Route }  from 'react-router-dom';
import { Provider }                     from 'react-redux';
import { reducers }                     from './store';
import { render }                       from 'react-dom';
import {
    applyMiddleware,
    combineReducers,
    createStore
} from 'redux';

// Routes
import Index                            from './screens/Index/Index';
import ImageView                        from './screens/ImageView';

// Global Styles
import './App.css';
import 'normalize.css';


// Create Global Store
const store = createStore(
    combineReducers(reducers),
    applyMiddleware(thunk)
);


// Main App
const App = () => (
    <Provider store={store}>
        <Router>
            <div className="dark">
                <Route exact path="/" component={Index} />
                <Route       path="/i/:uuid" component={ImageView} />
            </div>
        </Router>
    </Provider>
);


render(<App />, document.getElementById('root'));
