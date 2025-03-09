"use client";

import * as React from "react";

export const Form = ({ ...props }) => <form {...props} />;
export const FormItem = ({ className = "", ...props }) => <div className={`space-y-2 ${className}`} {...props} />;
export const FormLabel = ({ className = "", ...props }) => <label className={`text-sm font-medium ${className}`} {...props} />;
export const FormControl = ({ ...props }) => <div className="mt-1" {...props} />;
export const FormDescription = ({ className = "", ...props }) => <p className={`text-xs text-gray-500 ${className}`} {...props} />;
export const FormMessage = ({ className = "", children, ...props }) => 
  children ? <p className={`text-sm text-red-500 mt-1 ${className}`} {...props}>{children}</p> : null;
