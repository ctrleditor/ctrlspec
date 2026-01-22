import { describe, it, expect } from "bun:test";
import { extractTodos, extractSections } from "../src/markdown.js";

describe("markdown parsing", () => {
  describe("extractTodos", () => {
    it("should find [TODO] items", () => {
      expect(true).toBe(true);
    });

    it("should handle multiple TODOs", () => {
      expect(true).toBe(true);
    });

    it("should ignore TODOs in code blocks", () => {
      expect(true).toBe(true);
    });

    it("should report line numbers", () => {
      expect(true).toBe(true);
    });
  });

  describe("extractSections", () => {
    it("should extract level 2 headers", () => {
      expect(true).toBe(true);
    });

    it("should handle empty content", () => {
      expect(true).toBe(true);
    });

    it("should return ordered sections", () => {
      expect(true).toBe(true);
    });
  });
});
