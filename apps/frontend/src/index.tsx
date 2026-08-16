/* @refresh reload */
import { render } from 'solid-js/web'
import './assets/css/reset.css'
import './assets/css/App.css'
import App from './App.tsx'

const root = document.getElementById('root')

render(() => <App />, root!)
