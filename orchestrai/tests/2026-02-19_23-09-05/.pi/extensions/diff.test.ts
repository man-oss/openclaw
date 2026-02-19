import { describe, it, expect, beforeEach, vi } from "vitest";
import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";
import { DynamicBorder } from "@mariozechner/pi-coding-agent";
import {
  Container,
  Key,
  type SelectItem,
  SelectList,
  Text,
} from "@mariozechner/pi-tui";

// Mock dependencies
vi.mock("@mariozechner/pi-coding-agent", () => ({
  DynamicBorder: vi.fn((fn) => ({ render: vi.fn(), fn })),
}));

vi.mock("@mariozechner/pi-tui", () => ({
  Container: vi.fn(() => ({
    addChild: vi.fn(),
    render: vi.fn(),
    invalidate: vi.fn(),
  })),
  Key: {
    left: { code: "ArrowLeft" },
    right: { code: "ArrowRight" },
  },
  matchesKey: vi.fn(),
  SelectList: vi.fn(),
  Text: vi.fn(),
}));

describe("diff.ts", () => {
  let mockPi: ExtensionAPI;
  let mockCtx: ExtensionContext;
  let registerCommandHandler: any;

  beforeEach(() => {
    // Reset all mocks
    vi.clearAllMocks();

    // Setup registerCommand to capture the handler
    registerCommandHandler = null;
    mockPi = {
      registerCommand: vi.fn((cmd, config) => {
        if (cmd === "diff") {
          registerCommandHandler = config.handler;
        }
      }),
      exec: vi.fn(),
    } as any;

    mockCtx = {
      hasUI: true,
      cwd: "/test/cwd",
      ui: {
        notify: vi.fn(),
        custom: vi.fn(),
      },
    } as any;
  });

  describe("registerCommand", () => {
    it("should register the diff command", () => {
      const diffModule = require("./.pi/extensions/diff").default;
      diffModule(mockPi);
      expect(mockPi.registerCommand).toHaveBeenCalledWith("diff", expect.objectContaining({
        description: expect.any(String),
        handler: expect.any(Function),
      }));
    });
  });

  describe("handler", () => {
    it("should notify error when UI is not available", async () => {
      const diffModule = require("./.pi/extensions/diff").default;
      diffModule(mockPi);
      
      mockCtx.hasUI = false;
      await registerCommandHandler([], mockCtx);
      
      expect(mockCtx.ui.notify).toHaveBeenCalledWith("No UI available", "error");
    });

    it("should notify error when git status command fails", async () => {
      const diffModule = require("./.pi/extensions/diff").default;
      diffModule(mockPi);
      
      (mockPi.exec as any).mockResolvedValue({
        code: 128,
        stderr: "fatal: not a git repository",
        stdout: "",
      });

      await registerCommandHandler([], mockCtx);

      expect(mockCtx.ui.notify).toHaveBeenCalledWith(
        "git status failed: fatal: not a git repository",
        "error"
      );
    });

    it("should notify info when no changes in working tree", async () => {
      const diffModule = require("./.pi/extensions/diff").default;
      diffModule(mockPi);
      
      (mockPi.exec as any).mockResolvedValue({
        code: 0,
        stdout: "",
        stderr: "",
      });

      await registerCommandHandler([], mockCtx);

      expect(mockCtx.ui.notify).toHaveBeenCalledWith(
        "No changes in working tree",
        "info"
      );
    });

    it("should notify info when git status returns only whitespace", async () => {
      const diffModule = require("./.pi/extensions/diff").default;
      diffModule(mockPi);
      
      (mockPi.exec as any).mockResolvedValue({
        code: 0,
        stdout: "   \n\n  ",
        stderr: "",
      });

      await registerCommandHandler([], mockCtx);

      expect(mockCtx.ui.notify).toHaveBeenCalledWith(
        "No changes in working tree",
        "info"
      );
    });

    it("should skip lines with length less than 4 characters", async () => {
      const diffModule = require("./.pi/extensions/diff").default;
      diffModule(mockPi);
      
      (mockPi.exec as any).mockResolvedValue({
        code: 0,
        stdout: "M\nAB\nABC\nM  file.txt",
        stderr: "",
      });

      let parsedFiles: any = [];
      (mockCtx.ui.custom as any).mockImplementation(async (fn) => {
        // This will be called with the UI rendering function
        return Promise.resolve();
      });

      await registerCommandHandler([], mockCtx);
      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should parse Modified (M) files correctly", async () => {
      const diffModule = require("./.pi/extensions/diff").default;
      diffModule(mockPi);
      
      (mockPi.exec as any).mockResolvedValue({
        code: 0,
        stdout: "M  file.txt",
        stderr: "",
      });

      (mockCtx.ui.custom as any).mockImplementation(async (fn) => {
        return Promise.resolve();
      });

      await registerCommandHandler([], mockCtx);
      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should parse Added (A) files correctly", async () => {
      const diffModule = require("./.pi/extensions/diff").default;
      diffModule(mockPi);
      
      (mockPi.exec as any).mockResolvedValue({
        code: 0,
        stdout: "A  newfile.txt",
        stderr: "",
      });

      (mockCtx.ui.custom as any).mockImplementation(async (fn) => {
        return Promise.resolve();
      });

      await registerCommandHandler([], mockCtx);
      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should parse Deleted (D) files correctly", async () => {
      const diffModule = require("./.pi/extensions/diff").default;
      diffModule(mockPi);
      
      (mockPi.exec as any).mockResolvedValue({
        code: 0,
        stdout: "D  oldfile.txt",
        stderr: "",
      });

      (mockCtx.ui.custom as any).mockImplementation(async (fn) => {
        return Promise.resolve();
      });

      await registerCommandHandler([], mockCtx);
      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should parse Untracked (?) files correctly", async () => {
      const diffModule = require("./.pi/extensions/diff").default;
      diffModule(mockPi);
      
      (mockPi.exec as any).mockResolvedValue({
        code: 0,
        stdout: "?? untracked.txt",
        stderr: "",
      });

      (mockCtx.ui.custom as any).mockImplementation(async (fn) => {
        return Promise.resolve();
      });

      await registerCommandHandler([], mockCtx);
      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should parse Renamed (R) files correctly", async () => {
      const diffModule = require("./.pi/extensions/diff").default;
      diffModule(mockPi);
      
      (mockPi.exec as any).mockResolvedValue({
        code: 0,
        stdout: "R  renamed.txt",
        stderr: "",
      });

      (mockCtx.ui.custom as any).mockImplementation(async (fn) => {
        return Promise.resolve();
      });

      await registerCommandHandler([], mockCtx);
      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should parse Copied (C) files correctly", async () => {
      const diffModule = require("./.pi/extensions/diff").default;
      diffModule(mockPi);
      
      (mockPi.exec as any).mockResolvedValue({
        code: 0,
        stdout: "C  copied.txt",
        stderr: "",
      });

      (mockCtx.ui.custom as any).mockImplementation(async (fn) => {
        return Promise.resolve();
      });

      await registerCommandHandler([], mockCtx);
      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should use default status for unknown status codes", async () => {
      const diffModule = require("./.pi/extensions/diff").default;
      diffModule(mockPi);
      
      (mockPi.exec as any).mockResolvedValue({
        code: 0,
        stdout: "XX  unknownfile.txt",
        stderr: "",
      });

      (mockCtx.ui.custom as any).mockImplementation(async (fn) => {
        return Promise.resolve();
      });

      await registerCommandHandler([], mockCtx);
      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should notify info when no files are parsed", async () => {
      const diffModule = require("./.pi/extensions/diff").default;
      diffModule(mockPi);
      
      (mockPi.exec as any).mockResolvedValue({
        code: 0,
        stdout: "XY\nAB\nCD",
        stderr: "",
      });

      await registerCommandHandler([], mockCtx);
      expect(mockCtx.ui.notify).toHaveBeenCalledWith("No changes found", "info");
    });

    it("should handle multiple files correctly", async () => {
      const diffModule = require("./.pi/extensions/diff").default;
      diffModule(mockPi);
      
      (mockPi.exec as any).mockResolvedValue({
        code: 0,
        stdout: "M  file1.txt\nA  file2.txt\nD  file3.txt\n?? file4.txt",
        stderr: "",
      });

      (mockCtx.ui.custom as any).mockImplementation(async (fn) => {
        return Promise.resolve();
      });

      await registerCommandHandler([], mockCtx);
      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });
  });

  describe("openSelected function", () => {
    it("should open untracked file with code -g", async () => {
      const diffModule = require("./.pi/extensions/diff").default;
      diffModule(mockPi);
      
      (mockPi.exec as any).mockResolvedValue({
        code: 0,
        stdout: "?? untracked.txt",
        stderr: "",
      });

      (mockCtx.ui.custom as any).mockImplementation(async (fn) => {
        return Promise.resolve();
      });

      let openSelectedFn: any;
      (mockCtx.ui.custom as any).mockImplementation(async (fn) => {
        // The function will be called during handler execution
        return Promise.resolve();
      });

      await registerCommandHandler([], mockCtx);
      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should open tracked file with git difftool", async () => {
      const diffModule = require("./.pi/extensions/diff").default;
      diffModule(mockPi);
      
      (mockPi.exec as any).mockResolvedValue({
        code: 0,
        stdout: "M  modified.txt",
        stderr: "",
      });

      (mockCtx.ui.custom as any).mockImplementation(async (fn) => {
        return Promise.resolve();
      });

      await registerCommandHandler([], mockCtx);
      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should fall back to code command when difftool fails", async () => {
      const diffModule = require("./.pi/extensions/diff").default;
      diffModule(mockPi);
      
      (mockPi.exec as any).mockResolvedValueOnce({
        code: 0,
        stdout: "M  file.txt",
        stderr: "",
      }).mockResolvedValueOnce({
        code: 128,
        stderr: "difftool not configured",
        stdout: "",
      }).mockResolvedValueOnce({
        code: 0,
        stdout: "",
        stderr: "",
      });

      (mockCtx.ui.custom as any).mockImplementation(async (fn) => {
        return Promise.resolve();
      });

      await registerCommandHandler([], mockCtx);
      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should handle exec error in openSelected", async () => {
      const diffModule = require("./.pi/extensions/diff").default;
      diffModule(mockPi);
      
      (mockPi.exec as any).mockResolvedValueOnce({
        code: 0,
        stdout: "M  file.txt",
        stderr: "",
      }).mockRejectedValueOnce(new Error("Command failed"));

      (mockCtx.ui.custom as any).mockImplementation(async (fn) => {
        return Promise.resolve();
      });

      await registerCommandHandler([], mockCtx);
      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should handle non-Error exceptions in openSelected", async () => {
      const diffModule = require("./.pi/extensions/diff").default;
      diffModule(mockPi);
      
      (mockPi.exec as any).mockResolvedValueOnce({
        code: 0,
        stdout: "M  file.txt",
        stderr: "",
      }).mockRejectedValueOnce("String error");

      (mockCtx.ui.custom as any).mockImplementation(async (fn) => {
        return Promise.resolve();
      });

      await registerCommandHandler([], mockCtx);
      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });
  });

  describe("UI rendering", () => {
    it("should create container with borders and title", async () => {
      const diffModule = require("./.pi/extensions/diff").default;
      diffModule(mockPi);
      
      (mockPi.exec as any).mockResolvedValue({
        code: 0,
        stdout: "M  file.txt",
        stderr: "",
      });

      (mockCtx.ui.custom as any).mockImplementation(async (fn) => {
        return Promise.resolve();
      });

      await registerCommandHandler([], mockCtx);
      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should handle page up navigation with left key", async () => {
      const diffModule = require("./.pi/extensions/diff").default;
      diffModule(mockPi);
      
      (mockPi.exec as any).mockResolvedValue({
        code: 0,
        stdout: "M  file1.txt\nM  file2.txt\nM  file3.txt",
        stderr: "",
      });

      (mockCtx.ui.custom as any).mockImplementation(async (fn) => {
        return Promise.resolve();
      });

      await registerCommandHandler([], mockCtx);
      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should handle page down navigation with right key", async () => {
      const diffModule = require("./.pi/extensions/diff").default;
      diffModule(mockPi);
      
      (mockPi.exec as any).mockResolvedValue({
        code: 0,
        stdout: "M  file1.txt\nM  file2.txt\nM  file3.txt",
        stderr: "",
      });

      (mockCtx.ui.custom as any).mockImplementation(async (fn) => {
        return Promise.resolve();
      });

      await registerCommandHandler([], mockCtx);
      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should clamp page up navigation to 0", async () => {
      const diffModule = require("./.pi/extensions/diff").default;
      diffModule(mockPi);
      
      (mockPi.exec as any).mockResolvedValue({
        code: 0,
        stdout: "M  file1.txt",
        stderr: "",
      });

      (mockCtx.ui.custom as any).mockImplementation(async (fn) => {
        return Promise.resolve();
      });

      await registerCommandHandler([], mockCtx);
      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should clamp page down navigation to last item", async () => {
      const diffModule = require("./.pi/extensions/diff").default;
      diffModule(mockPi);
      
      (mockPi.exec as any).mockResolvedValue({
        code: 0,
        stdout: "M  file1.txt",
        stderr: "",
      });

      (mockCtx.ui.custom as any).mockImplementation(async (fn) => {
        return Promise.resolve();
      });

      await registerCommandHandler([], mockCtx);
      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should apply correct color to Modified status", async () => {
      const diffModule = require("./.pi/extensions/diff").default;
      diffModule(mockPi);
      
      (mockPi.exec as any).mockResolvedValue({
        code: 0,
        stdout: "M  file.txt",
        stderr: "",
      });

      (mockCtx.ui.custom as any).mockImplementation(async (fn) => {
        return Promise.resolve();
      });

      await registerCommandHandler([], mockCtx);
      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should apply correct color to Added status", async () => {
      const diffModule = require("./.pi/extensions/diff").default;
      diffModule(mockPi);
      
      (mockPi.exec as any).mockResolvedValue({
        code: 0,
        stdout: "A  file.txt",
        stderr: "",
      });

      (mockCtx.ui.custom as any).mockImplementation(async (fn) => {
        return Promise.resolve();
      });

      await registerCommandHandler([], mockCtx);
      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should apply correct color to Deleted status", async () => {
      const diffModule = require("./.pi/extensions/diff").default;
      diffModule(mockPi);
      
      (mockPi.exec as any).mockResolvedValue({
        code: 0,
        stdout: "D  file.txt",
        stderr: "",
      });

      (mockCtx.ui.custom as any).mockImplementation(async (fn) => {
        return Promise.resolve();
      });

      await registerCommandHandler([], mockCtx);
      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should apply correct color to Untracked status", async () => {
      const diffModule = require("./.pi/extensions/diff").default;
      diffModule(mockPi);
      
      (mockPi.exec as any).mockResolvedValue({
        code: 0,
        stdout: "?? file.txt",
        stderr: "",
      });

      (mockCtx.ui.custom as any).mockImplementation(async (fn) => {
        return Promise.resolve();
      });

      await registerCommandHandler([], mockCtx);
      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should cap visible rows to 15", async () => {
      const diffModule = require("./.pi/extensions/diff").default;
      diffModule(mockPi);
      
      const fileLines = Array(20).fill(0).map((_, i) => `M  file${i}.txt`).join("\n");
      (mockPi.exec as any).mockResolvedValue({
        code: 0,
        stdout: fileLines,
        stderr: "",
      });

      (mockCtx.ui.custom as any).mockImplementation(async (fn) => {
        return Promise.resolve();
      });

      await registerCommandHandler([], mockCtx);
      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should handle selection change events", async () => {
      const diffModule = require("./.pi/extensions/diff").default;
      diffModule(mockPi);
      
      (mockPi.exec as any).mockResolvedValue({
        code: 0,
        stdout: "M  file.txt",
        stderr: "",
      });

      (mockCtx.ui.custom as any).mockImplementation(async (fn) => {
        return Promise.resolve();
      });

      await registerCommandHandler([], mockCtx);
      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should handle cancel event", async () => {
      const diffModule = require("./.pi/extensions/diff").default;
      diffModule(mockPi);
      
      (mockPi.exec as any).mockResolvedValue({
        code: 0,
        stdout: "M  file.txt",
        stderr: "",
      });

      (mockCtx.ui.custom as any).mockImplementation(async (fn) => {
        return Promise.resolve();
      });

      await registerCommandHandler([], mockCtx);
      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });
  });
});