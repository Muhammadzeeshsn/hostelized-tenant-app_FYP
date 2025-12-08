// components/IdentityAddressStep.jsx
import React, { useState } from 'react';

const IdentityAddressStep = ({ formData, setFormData }) => {
  const [errors, setErrors] = useState({});

  const countries = ['Pakistan', 'India', 'United States', 'United Kingdom', 'Canada'];
  const provinces = {
    Pakistan: ['Punjab', 'Sindh', 'Khyber Pakhtunkhwa', 'Balochistan', 'Gilgit-Baltistan'],
    India: ['Delhi', 'Maharashtra', 'Karnataka', 'Tamil Nadu', 'Uttar Pradesh'],
    'United States': ['California', 'Texas', 'New York', 'Florida', 'Illinois'],
    'United Kingdom': ['England', 'Scotland', 'Wales', 'Northern Ireland'],
    Canada: ['Ontario', 'Quebec', 'British Columbia', 'Alberta', 'Manitoba']
  };

  const formatCNIC = (value) => {
    // Remove all non-digits
    const cleaned = value.replace(/\D/g, '');
    
    // Format: 12345-1234567-1
    if (cleaned.length <= 5) {
      return cleaned;
    } else if (cleaned.length <= 12) {
      return `${cleaned.slice(0, 5)}-${cleaned.slice(5)}`;
    } else {
      return `${cleaned.slice(0, 5)}-${cleaned.slice(5, 12)}-${cleaned.slice(12, 13)}`;
    }
  };

  const handleCNICChange = (e) => {
    const formatted = formatCNIC(e.target.value);
    setFormData(prev => ({
      ...prev,
      cnic: formatted
    }));

    // Validate CNIC format
    if (formatted.length === 15 && !/^\d{5}-\d{7}-\d$/.test(formatted)) {
      setErrors(prev => ({ ...prev, cnic: 'Invalid CNIC format' }));
    } else {
      setErrors(prev => ({ ...prev, cnic: '' }));
    }
  };

  const handleDocumentTypeChange = (type) => {
    setFormData(prev => ({ 
      ...prev, 
      documentType: type,
      cnic: type === 'CNIC' ? prev.cnic : '',
      passport: type === 'Passport' ? prev.passport : ''
    }));
    setErrors(prev => ({ ...prev, cnic: '', passport: '' }));
  };

  const handleFileUpload = (fileType, file) => {
    setFormData(prev => ({ ...prev, [fileType]: file }));
  };

  const validateField = (name, value) => {
    switch (name) {
      case 'cnic':
        if (!value) return 'CNIC is required';
        if (!/^\d{5}-\d{7}-\d$/.test(value)) return 'Invalid CNIC format';
        return '';
      case 'passport':
        if (!value && formData.documentType === 'Passport') return 'Passport number is required';
        return '';
      case 'completeAddress':
        if (!value.trim()) return 'Complete address is required';
        return '';
      default:
        return '';
    }
  };

  const handleBlur = (e) => {
    const { name, value } = e.target;
    const error = validateField(name, value);
    setErrors(prev => ({ ...prev, [name]: error }));
  };

  const renderDocumentInput = () => {
    if (formData.documentType === 'CNIC') {
      return (
        <div className="form-group">
          <label className="form-label required">CNIC Number</label>
          <input
            type="text"
            name="cnic"
            value={formData.cnic}
            onChange={handleCNICChange}
            onBlur={handleBlur}
            placeholder="12345-1234567-1"
            className={`form-input ${errors.cnic ? 'error' : ''}`}
            maxLength="15"
          />
          {errors.cnic && <div className="error-message">⚠️ {errors.cnic}</div>}
          <div className="help-text">Enter CNIC in format: 12345-1234567-1</div>
        </div>
      );
    } else {
      return (
        <div className="form-group">
          <label className="form-label required">Passport Number</label>
          <input
            type="text"
            name="passport"
            value={formData.passport}
            onChange={(e) => setFormData(prev => ({ ...prev, passport: e.target.value }))}
            onBlur={handleBlur}
            placeholder="AB1234567"
            className={`form-input ${errors.passport ? 'error' : ''}`}
          />
          {errors.passport && <div className="error-message">⚠️ {errors.passport}</div>}
        </div>
      );
    }
  };

  const renderUploadSection = () => {
    if (formData.documentType === 'CNIC') {
      return (
        <div className="upload-section">
          <h3 className="upload-title">Upload CNIC Photos (Both sides required)</h3>
          <div className="upload-grid">
            <div 
              className="upload-box"
              onClick={() => document.getElementById('cnicFront').click()}
            >
              <div className="upload-icon">📷</div>
              <div className="upload-text">CNIC Front</div>
              <input
                type="file"
                id="cnicFront"
                accept="image/*"
                style={{ display: 'none' }}
                onChange={(e) => handleFileUpload('cnicFront', e.target.files[0])}
              />
              {formData.cnicFront && (
                <div className="file-name">✓ {formData.cnicFront.name}</div>
              )}
            </div>
            
            <div 
              className="upload-box"
              onClick={() => document.getElementById('cnicBack').click()}
            >
              <div className="upload-icon">📷</div>
              <div className="upload-text">CNIC Back</div>
              <input
                type="file"
                id="cnicBack"
                accept="image/*"
                style={{ display: 'none' }}
                onChange={(e) => handleFileUpload('cnicBack', e.target.files[0])}
              />
              {formData.cnicBack && (
                <div className="file-name">✓ {formData.cnicBack.name}</div>
              )}
            </div>
          </div>
        </div>
      );
    } else {
      return (
        <div className="upload-section">
          <h3 className="upload-title">Upload Passport</h3>
          <div className="upload-grid">
            <div 
              className="upload-box"
              onClick={() => document.getElementById('passportPhoto').click()}
              style={{ gridColumn: '1 / -1' }}
            >
              <div className="upload-icon">🛂</div>
              <div className="upload-text">Passport Photo Page</div>
              <input
                type="file"
                id="passportPhoto"
                accept="image/*"
                style={{ display: 'none' }}
                onChange={(e) => handleFileUpload('passportPhoto', e.target.files[0])}
              />
              {formData.passportPhoto && (
                <div className="file-name">✓ {formData.passportPhoto.name}</div>
              )}
            </div>
          </div>
        </div>
      );
    }
  };

  return (
    <div className="step-container fade-in">
      <h2 style={{ marginBottom: '30px' }}>Identity & Address</h2>
      <p style={{ color: '#666', marginBottom: '30px' }}>
        Verify your identity and provide current address
      </p>

      <div className="form-group">
        <label className="form-label required">Complete Address</label>
        <textarea
          name="completeAddress"
          value={formData.completeAddress}
          onChange={(e) => setFormData(prev => ({ ...prev, completeAddress: e.target.value }))}
          onBlur={handleBlur}
          className={`form-input ${errors.completeAddress ? 'error' : ''}`}
          rows="3"
          placeholder="Enter your complete address"
        />
        {errors.completeAddress && <div className="error-message">⚠️ {errors.completeAddress}</div>}
      </div>

      <div className="form-row" style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '20px' }}>
        <div className="form-group">
          <label className="form-label required">Country</label>
          <select
            value={formData.country}
            onChange={(e) => setFormData(prev => ({ 
              ...prev, 
              country: e.target.value,
              province: '' // Reset province when country changes
            }))}
            className="form-input"
          >
            {countries.map(country => (
              <option key={country} value={country}>{country}</option>
            ))}
          </select>
        </div>

        <div className="form-group">
          <label className="form-label required">Province/State</label>
          <select
            value={formData.province}
            onChange={(e) => setFormData(prev => ({ ...prev, province: e.target.value }))}
            className="form-input"
          >
            <option value="">Select Province/State</option>
            {provinces[formData.country]?.map(province => (
              <option key={province} value={province.toLowerCase()}>
                {province}
              </option>
            ))}
          </select>
        </div>
      </div>

      <div className="form-group">
        <label className="form-label required">Document Type</label>
        <div className="document-type-selector">
          <button
            type="button"
            className={`doc-type-btn ${formData.documentType === 'CNIC' ? 'active' : ''}`}
            onClick={() => handleDocumentTypeChange('CNIC')}
          >
            <span style={{ fontSize: '1.5em' }}>🆔</span>
            <span>CNIC</span>
          </button>
          <button
            type="button"
            className={`doc-type-btn ${formData.documentType === 'Passport' ? 'active' : ''}`}
            onClick={() => handleDocumentTypeChange('Passport')}
          >
            <span style={{ fontSize: '1.5em' }}>🛂</span>
            <span>Passport</span>
          </button>
        </div>
      </div>

      {renderDocumentInput()}
      {renderUploadSection()}
    </div>
  );
};

export default IdentityAddressStep;