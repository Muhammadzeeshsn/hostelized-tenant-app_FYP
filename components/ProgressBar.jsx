// components/ProgressBar.jsx
import React from 'react';
import './ProgressBar.css';

const ProgressBar = ({ steps, currentStep }) => {
  return (
    <div className="progress-container">
      <div className="progress-bar">
        <div 
          className="progress-fill"
          style={{ width: `${((currentStep - 1) / (steps.length - 1)) * 100}%` }}
        />
      </div>
      
      <div className="steps">
        {steps.map((step, index) => (
          <div 
            key={step.id} 
            className={`step ${index + 1 === currentStep ? 'active' : ''} ${index + 1 < currentStep ? 'completed' : ''}`}
          >
            <div className="step-number">
              {index + 1 < currentStep ? '✓' : index + 1}
            </div>
            <div className="step-label">{step.name}</div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default ProgressBar;