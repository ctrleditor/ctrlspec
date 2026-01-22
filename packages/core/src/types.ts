/**
 * Core types for Portolan documentation system
 */

export interface PortolanDoc {
  path: string;
  name:
    | "llm"
    | "requirements"
    | "architecture"
    | "constraints"
    | "decisions"
    | "testing"
    | "deployment";
  content: string;
  exists: boolean;
}

export interface TodoItem {
  file: string;
  line: number;
  text: string;
}

export interface ValidationStats {
  totalDocs: number;
  completeDocs: number;
  missingDocs: string[];
  todoCount: number;
  todos: TodoItem[];
}

export interface ValidationError {
  file: string;
  message: string;
  severity: "error" | "warning";
}

export interface ValidationWarning {
  file: string;
  message: string;
}

export interface ValidationResult {
  valid: boolean;
  stats: ValidationStats;
  errors: ValidationError[];
  warnings: ValidationWarning[];
}
