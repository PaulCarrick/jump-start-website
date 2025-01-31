// /app/javascripts/components/ErrorBoundary.jsx

// Handle Errors

import React from "react";
import PropTypes from "prop-types";

class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error) {
    // Update state so the next render shows the fallback UI
    return { hasError: true };
  }

  componentDidCatch(error, errorInfo) {
    // You can log the error and errorInfo to an error reporting service
    debugger;
    console.error("ErrorBoundary caught an error", error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      // Render fallback UI
      debugger;
      return <h1>Something went wrong. Please try again later.</h1>;
    }

    // Render children if no error
    return this.props.children;
  }
}

// Add prop validation
ErrorBoundary.propTypes = {
  children: PropTypes.node.isRequired, // Expect children to be React nodes and required
};

export default ErrorBoundary;
