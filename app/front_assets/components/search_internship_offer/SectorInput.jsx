import React, { useState, useRef, useEffect } from 'react';

const SectorInput = ({ sectors, selectedSectorIds, onChange }) => {
  const [isOpen, setIsOpen] = useState(false);
  const containerRef = useRef(null);

  // Close on click outside
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (containerRef.current && !containerRef.current.contains(event.target)) {
        setIsOpen(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [containerRef]);

  const handleCheckboxChange = (sectorId) => {
    const newIds = selectedSectorIds.includes(sectorId)
      ? selectedSectorIds.filter(id => id !== sectorId)
      : [...selectedSectorIds, sectorId];
    onChange(newIds);
  };

  const placeholder = selectedSectorIds.length === 0
    ? "Secteurs d'activité"
    : `${selectedSectorIds.length} secteur${selectedSectorIds.length > 1 ? 's' : ''}`;

  return (
    <div className='fr-input-group mb-md-0 col-md '>
    <div className="fr-select-group" ref={containerRef} style={{ position: 'relative' }}>
      <label className="fr-label" htmlFor="sector-input-button">
        Secteurs d'activité
      </label>
      <button
        type="button"
        id="sector-input-button"
        className="fr-select text-left"
        onClick={() => setIsOpen(!isOpen)}
        style={{ justifyContent: 'space-between', display: 'flex', alignItems: 'center' }}
      >
        {placeholder}
      </button>

      {isOpen && (
        <div 
          className="fr-p-2w" 
          style={{
            position: 'absolute',
            top: '100%',
            left: 0,
            right: 0,
            backgroundColor: 'white',
            border: '1px solid #ddd',
            boxShadow: '0 4px 6px rgba(0,0,0,0.1)',
            zIndex: 1000,
            maxHeight: '300px',
            overflowY: 'auto'
          }}
        >
          {sectors && sectors.map(sector => (
            <div key={sector.id} className="fr-checkbox-group fr-checkbox-group--sm">
              <input
                type="checkbox"
                id={`sector-${sector.id}`}
                name="sector_ids[]"
                checked={selectedSectorIds.includes(sector.id)}
                onChange={() => handleCheckboxChange(sector.id)}
              />
              <label className="fr-label" htmlFor={`sector-${sector.id}`}>
                {sector.name}
              </label>
            </div>
          ))}
        </div>
      )}
    </div>
    </div>
  );
};

export default SectorInput;

