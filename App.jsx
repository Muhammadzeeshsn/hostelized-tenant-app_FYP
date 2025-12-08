// App.jsx (Main Component)
import React, { useState } from 'react';
import './App.css';
import ProgressBar from './components/ProgressBar';
import IdentityAddressStep from './components/IdentityAddressStep';
import { Toaster, toast } from 'react-hot-toast';

function App() {
  const [currentStep, setCurrentStep] = useState(1);
  const [showSkip, setShowSkip] = useState(true);
  const [formData, setFormData] = useState({
    completeAddress: '',
    country: 'Pakistan',
    province: '',
    documentType: 'CNIC',
    cnic: '',
    passport: '',
    cnicFront: null,
    cnicBack: null,
    passportPhoto: null
  });

  const steps = [
    { id: 1, name: 'Identity & Address' },
    { id: 2, name: 'Personal Details' },
    { id: 3, name: 'Verification' },
    { id: 4, name: 'Confirmation' }
  ];

  const handleSkip = () => {
    setShowSkip(false);
    toast.success('Registration skipped for UI review only', {
      duration: 3000,
      icon: '👁️'
    });
  };

  const handleNext = () => {
    if (currentStep < steps.length) {
      setCurrentStep(prev => prev + 1);
    }
  };

  const handleBack = () => {
    if (currentStep > 1) {
      setCurrentStep(prev => prev - 1);
    }
  };

  const handleSubmit = () => {
    toast.success('Registration submitted successfully!');
  };

  return (
    <div className="app-container">
      <Toaster position="top-right" />
      
      {showSkip && (
        <button 
          className="skip-button"
          onClick={handleSkip}
        >
          ⚡ Skip Registration 
          <span className="skip-note">(UI Review Only - Will be removed)</span>
        </button>
      )}

      <div className="registration-card">
        <div className="card-header">
          <h1 className="main-title">Complete Your Registration</h1>
          <p className="subtitle">Follow the steps to verify your identity</p>
        </div>

        <ProgressBar 
          steps={steps} 
          currentStep={currentStep} 
        />

        <div className="step-content">
          {currentStep === 1 && (
            <IdentityAddressStep
              formData={formData}
              setFormData={setFormData}
            />
          )}
          
          {currentStep === 2 && (
            <div className="step-container fade-in">
              <h2>Personal Details</h2>
              <p>This is step 2 - Personal Details</p>
            </div>
          )}
          
          {currentStep === 3 && (
            <div className="step-container fade-in">
              <h2>Verification</h2>
              <p>This is step 3 - Verification</p>
            </div>
          )}
          
          {currentStep === 4 && (
            <div className="step-container fade-in">
              <h2>Confirmation</h2>
              <p>This is step 4 - Confirmation</p>
            </div>
          )}
        </div>

        <div className="navigation-buttons">
          <button 
            className="btn btn-secondary"
            onClick={handleBack}
            disabled={currentStep === 1}
          >
            ← Back
          </button>
          
          {currentStep < steps.length ? (
            <button 
              className="btn btn-primary"
              onClick={handleNext}
            >
              Continue →
            </button>
          ) : (
            <button 
              className="btn btn-success"
              onClick={handleSubmit}
            >
              Submit Registration ✓
            </button>
          )}
        </div>
      </div>
    </div>
  );
}

export default App;