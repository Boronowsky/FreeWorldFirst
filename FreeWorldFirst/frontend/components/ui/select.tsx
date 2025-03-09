"use client";

import * as React from "react";

export interface SelectProps extends React.SelectHTMLAttributes<HTMLSelectElement> {}

export const Select = React.forwardRef<HTMLSelectElement, SelectProps>(
  ({ className, children, ...props }, ref) => {
    return (
      <select
        className={`flex h-10 w-full rounded-md border border-input bg-transparent px-3 py-2 text-sm placeholder:text-muted-foreground focus:outline-none focus:ring-1 focus:ring-blue-400 disabled:cursor-not-allowed disabled:opacity-50 ${className}`}
        ref={ref}
        {...props}
      >
        {children}
      </select>
    );
  }
);

Select.displayName = "Select";

export const SelectTrigger = ({ className, children, ...props }: React.HTMLAttributes<HTMLDivElement>) => {
  return (
    <div className={`relative flex h-10 w-full items-center justify-between rounded-md border border-input bg-transparent px-3 py-2 text-sm placeholder:text-muted-foreground focus:outline-none disabled:cursor-not-allowed disabled:opacity-50 ${className}`} {...props}>
      {children}
    </div>
  );
};

export const SelectValue = ({ className, ...props }: React.HTMLAttributes<HTMLSpanElement>) => {
  return <span className={`block truncate ${className}`} {...props} />;
};

export const SelectContent = ({ className, children, ...props }: React.HTMLAttributes<HTMLDivElement>) => {
  return (
    <div className={`relative mt-1 max-h-60 w-full overflow-auto rounded-md border bg-white py-1 text-base shadow-lg focus:outline-none sm:text-sm ${className}`} {...props}>
      {children}
    </div>
  );
};

export const SelectItem = ({ className, children, ...props }: React.HTMLAttributes<HTMLDivElement>) => {
  return (
    <div className={`relative cursor-default select-none py-2 pl-10 pr-4 text-gray-900 hover:bg-blue-50 ${className}`} {...props}>
      {children}
    </div>
  );
};
