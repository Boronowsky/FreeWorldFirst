// components/ui/select.tsx
"use client";

import { useEffect, useRef, useState } from "react";
import useOutsideClick from "../../lib/hooks/useOutsideClick";

interface DropdownItem {
  id: string;
  name: string;
}

interface SelectProps {
  value: string;
  onValueChange: (value: string) => void;
  placeholder?: string;
  options: string[];
  className?: string;
}

export function Select({
  value,
  onValueChange,
  placeholder = "Auswählen...",
  options,
  className = "",
}: SelectProps) {
  const [isOpen, setIsOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  useOutsideClick({
    ref: dropdownRef,
    handler: () => setIsOpen(false),
  });

  const handleSelect = (option: string) => {
    onValueChange(option);
    setIsOpen(false);
  };

  return (
    <div ref={dropdownRef} className="relative">
      <button
        type="button"
        className={`flex h-10 w-full items-center justify-between rounded-md border border-input bg-transparent px-3 py-2 text-sm focus:outline-none ${className}`}
        onClick={() => setIsOpen(!isOpen)}
        aria-haspopup="listbox"
        aria-expanded={isOpen}
      >
        <span className={value ? "" : "text-muted-foreground"}>
          {value || placeholder}
        </span>
        <svg 
          xmlns="http://www.w3.org/2000/svg" 
          width="24" 
          height="24" 
          viewBox="0 0 24 24" 
          fill="none" 
          stroke="currentColor" 
          strokeWidth="2" 
          strokeLinecap="round" 
          strokeLinejoin="round" 
          className={`h-4 w-4 opacity-50 transition-transform ${isOpen ? 'rotate-180' : ''}`}
        >
          <path d="m6 9 6 6 6-6" />
        </svg>
      </button>
      
      {isOpen && (
        <div className="absolute z-50 w-full mt-1 rounded-md border bg-white shadow-lg">
          <ul 
            className="py-1 max-h-60 overflow-auto"
            role="listbox"
          >
            {options.map((option) => (
              <li
                key={option}
                role="option"
                aria-selected={value === option}
                className={`px-3 py-2 cursor-pointer hover:bg-blue-50 ${
                  value === option ? 'bg-blue-100' : ''
                }`}
                onClick={() => handleSelect(option)}
              >
                {option}
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
}

// Export leere Komponenten für Kompatibilität
export const SelectTrigger = ({ children }) => children;
export const SelectValue = ({ children }) => children;
export const SelectContent = ({ children }) => children;
export const SelectItem = ({ children }) => children;