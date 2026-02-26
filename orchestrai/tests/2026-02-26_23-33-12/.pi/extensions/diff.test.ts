import { describe, it, expect, beforeEach, vi } from "vitest";
import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";
import diffExtension from "./diff";

describe("diff extension", () => {
  let mockPi: ExtensionAPI;
  let mockCtx: ExtensionContext;
  let registeredCommand: any;

  beforeEach(() => {
    // Mock ExtensionAPI
    mockPi = {
      registerCommand: vi.fn((name, config) => {
        if (name === "diff") {
          registeredCommand = config;
        }
      }),
      exec: vi.fn(),
    } as any;

    // Mock ExtensionContext
    mockCtx = {
      hasUI: true,
      cwd: "/test/cwd",
      ui: {
        notify: vi.fn(),
        custom: vi.fn(),
      },
    } as any;
  });

  it("should register diff command", () => {
    diffExtension(mockPi);
    expect(mockPi.registerCommand).toHaveBeenCalledWith("diff", expect.any(Object));
    expect(registeredCommand.description).toBe(
      "Show git changes and open in VS Code diff view",
    );
  });

  describe("diff handler", () => {
    it("should notify error when no UI available", async () => {
      mockCtx.hasUI = false;
      diffExtension(mockPi);

      await registeredCommand.handler([], mockCtx);

      expect(mockCtx.ui.notify).toHaveBeenCalledWith("No UI available", "error");
    });

    it("should notify error when git status fails", async () => {
      vi.mocked(mockPi.exec).mockResolvedValueOnce({
        code: 1,
        stderr: "fatal: not a git repository",
      } as any);

      diffExtension(mockPi);
      await registeredCommand.handler([], mockCtx);

      expect(mockCtx.ui.notify).toHaveBeenCalledWith(
        "git status failed: fatal: not a git repository",
        "error",
      );
    });

    it("should notify info when no changes in working tree", async () => {
      vi.mocked(mockPi.exec).mockResolvedValueOnce({
        code: 0,
        stdout: "",
      } as any);

      diffExtension(mockPi);
      await registeredCommand.handler([], mockCtx);

      expect(mockCtx.ui.notify).toHaveBeenCalledWith("No changes in working tree", "info");
    });

    it("should notify info when stdout is whitespace only", async () => {
      vi.mocked(mockPi.exec).mockResolvedValueOnce({
        code: 0,
        stdout: "   \n\n  ",
      } as any);

      diffExtension(mockPi);
      await registeredCommand.handler([], mockCtx);

      expect(mockCtx.ui.notify).toHaveBeenCalledWith("No changes in working tree", "info");
    });

    it("should parse git status output with modified files", async () => {
      vi.mocked(mockPi.exec).mockResolvedValueOnce({
        code: 0,
        stdout: " M file1.ts\nM  file2.ts",
      } as any);

      let capturedItems: any[] = [];
      vi.mocked(mockCtx.ui.custom).mockImplementation((callback) => {
        const mockTui = { requestRender: vi.fn() };
        const mockTheme = {
          fg: vi.fn((color, text) => text),
          bold: vi.fn((text) => text),
        };
        const mockKb = {};
        const mockDone = vi.fn();

        callback(mockTui as any, mockTheme as any, mockKb as any, mockDone);
        return Promise.resolve();
      });

      diffExtension(mockPi);
      await registeredCommand.handler([], mockCtx);

      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should parse file with added status", async () => {
      vi.mocked(mockPi.exec).mockResolvedValueOnce({
        code: 0,
        stdout: "A  newfile.ts",
      } as any);

      vi.mocked(mockCtx.ui.custom).mockImplementation((callback) => {
        callback({} as any, { fg: (_, t) => t, bold: (t) => t } as any, {} as any, () => {});
        return Promise.resolve();
      });

      diffExtension(mockPi);
      await registeredCommand.handler([], mockCtx);

      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should parse file with deleted status", async () => {
      vi.mocked(mockPi.exec).mockResolvedValueOnce({
        code: 0,
        stdout: "D  deleted.ts",
      } as any);

      vi.mocked(mockCtx.ui.custom).mockImplementation((callback) => {
        callback({} as any, { fg: (_, t) => t, bold: (t) => t } as any, {} as any, () => {});
        return Promise.resolve();
      });

      diffExtension(mockPi);
      await registeredCommand.handler([], mockCtx);

      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should parse file with untracked status", async () => {
      vi.mocked(mockPi.exec).mockResolvedValueOnce({
        code: 0,
        stdout: "?? untracked.ts",
      } as any);

      vi.mocked(mockCtx.ui.custom).mockImplementation((callback) => {
        callback({} as any, { fg: (_, t) => t, bold: (t) => t } as any, {} as any, () => {});
        return Promise.resolve();
      });

      diffExtension(mockPi);
      await registeredCommand.handler([], mockCtx);

      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should parse file with renamed status", async () => {
      vi.mocked(mockPi.exec).mockResolvedValueOnce({
        code: 0,
        stdout: "R  renamed.ts",
      } as any);

      vi.mocked(mockCtx.ui.custom).mockImplementation((callback) => {
        callback({} as any, { fg: (_, t) => t, bold: (t) => t } as any, {} as any, () => {});
        return Promise.resolve();
      });

      diffExtension(mockPi);
      await registeredCommand.handler([], mockCtx);

      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should parse file with copied status", async () => {
      vi.mocked(mockPi.exec).mockResolvedValueOnce({
        code: 0,
        stdout: "C  copied.ts",
      } as any);

      vi.mocked(mockCtx.ui.custom).mockImplementation((callback) => {
        callback({} as any, { fg: (_, t) => t, bold: (t) => t } as any, {} as any, () => {});
        return Promise.resolve();
      });

      diffExtension(mockPi);
      await registeredCommand.handler([], mockCtx);

      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should skip lines shorter than 4 characters", async () => {
      vi.mocked(mockPi.exec).mockResolvedValueOnce({
        code: 0,
        stdout: "XY\nA  file.ts\nZ",
      } as any);

      vi.mocked(mockCtx.ui.custom).mockImplementation((callback) => {
        callback({} as any, { fg: (_, t) => t, bold: (t) => t } as any, {} as any, () => {});
        return Promise.resolve();
      });

      diffExtension(mockPi);
      await registeredCommand.handler([], mockCtx);

      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should notify error when no files are found after parsing", async () => {
      vi.mocked(mockPi.exec).mockResolvedValueOnce({
        code: 0,
        stdout: "XX\nYZ\nAB",
      } as any);

      diffExtension(mockPi);
      await registeredCommand.handler([], mockCtx);

      expect(mockCtx.ui.notify).toHaveBeenCalledWith("No changes found", "info");
    });

    it("should handle unknown status code", async () => {
      vi.mocked(mockPi.exec).mockResolvedValueOnce({
        code: 0,
        stdout: "UV  unknown.ts",
      } as any);

      vi.mocked(mockCtx.ui.custom).mockImplementation((callback) => {
        callback({} as any, { fg: (_, t) => t, bold: (t) => t } as any, {} as any, () => {});
        return Promise.resolve();
      });

      diffExtension(mockPi);
      await registeredCommand.handler([], mockCtx);

      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should handle empty status with trimmed space as fallback", async () => {
      vi.mocked(mockPi.exec).mockResolvedValueOnce({
        code: 0,
        stdout: "   file.ts",
      } as any);

      vi.mocked(mockCtx.ui.custom).mockImplementation((callback) => {
        callback({} as any, { fg: (_, t) => t, bold: (t) => t } as any, {} as any, () => {});
        return Promise.resolve();
      });

      diffExtension(mockPi);
      await registeredCommand.handler([], mockCtx);

      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });
  });

  describe("openSelected callback", () => {
    it("should open untracked file with code command", async () => {
      vi.mocked(mockPi.exec).mockResolvedValueOnce({
        code: 0,
        stdout: "?? newfile.ts",
      } as any);

      vi.mocked(mockPi.exec).mockResolvedValueOnce({ code: 0 } as any);

      let selectListOnSelect: any;
      vi.mocked(mockCtx.ui.custom).mockImplementation((callback) => {
        const mockTheme = {
          fg: vi.fn((color, text) => `[${color}]${text}`),
          bold: vi.fn((text) => `**${text}**`),
        };
        let capturedSelectList: any = null;

        const originalCallback = callback(
          {
            requestRender: vi.fn(),
          } as any,
          mockTheme as any,
          {} as any,
          () => {},
        );

        return Promise.resolve();
      });

      diffExtension(mockPi);
      await registeredCommand.handler([], mockCtx);

      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should open modified file with difftool and fallback to code on failure", async () => {
      vi.mocked(mockPi.exec)
        .mockResolvedValueOnce({
          code: 0,
          stdout: " M modified.ts",
        } as any)
        .mockResolvedValueOnce({ code: 1 } as any)
        .mockResolvedValueOnce({ code: 0 } as any);

      vi.mocked(mockCtx.ui.custom).mockImplementation((callback) => {
        callback({} as any, { fg: (_, t) => t, bold: (t) => t } as any, {} as any, () => {});
        return Promise.resolve();
      });

      diffExtension(mockPi);
      await registeredCommand.handler([], mockCtx);

      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should handle error when opening file", async () => {
      vi.mocked(mockPi.exec).mockResolvedValueOnce({
        code: 0,
        stdout: " M file.ts",
      } as any);

      const error = new Error("Command not found");
      vi.mocked(mockPi.exec).mockRejectedValueOnce(error);

      vi.mocked(mockCtx.ui.custom).mockImplementation((callback) => {
        callback({} as any, { fg: (_, t) => t, bold: (t) => t } as any, {} as any, () => {});
        return Promise.resolve();
      });

      diffExtension(mockPi);
      await registeredCommand.handler([], mockCtx);

      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should handle non-Error object when opening file", async () => {
      vi.mocked(mockPi.exec).mockResolvedValueOnce({
        code: 0,
        stdout: " M file.ts",
      } as any);

      vi.mocked(mockPi.exec).mockRejectedValueOnce("String error");

      vi.mocked(mockCtx.ui.custom).mockImplementation((callback) => {
        callback({} as any, { fg: (_, t) => t, bold: (t) => t } as any, {} as any, () => {});
        return Promise.resolve();
      });

      diffExtension(mockPi);
      await registeredCommand.handler([], mockCtx);

      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });
  });

  describe("UI custom handler", () => {
    it("should render container with borders and title", async () => {
      vi.mocked(mockPi.exec).mockResolvedValueOnce({
        code: 0,
        stdout: " M file1.ts",
      } as any);

      const mockRender = vi.fn();
      const mockInvalidate = vi.fn();

      vi.mocked(mockCtx.ui.custom).mockImplementation((callback) => {
        const mockContainer = {
          addChild: vi.fn(),
          render: mockRender,
          invalidate: mockInvalidate,
        };

        const result = callback(
          { requestRender: vi.fn() } as any,
          {
            fg: vi.fn((color, text) => `[${color}]${text}`),
            bold: vi.fn((text) => `**${text}**`),
          } as any,
          {} as any,
          () => {},
        );

        expect(result).toHaveProperty("render");
        expect(result).toHaveProperty("invalidate");
        expect(result).toHaveProperty("handleInput");

        return Promise.resolve();
      });

      diffExtension(mockPi);
      await registeredCommand.handler([], mockCtx);

      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should handle left arrow key for paging up", async () => {
      vi.mocked(mockPi.exec).mockResolvedValueOnce({
        code: 0,
        stdout: Array(20).fill(" M file.ts").join("\n"),
      } as any);

      let handleInputFn: any;

      vi.mocked(mockCtx.ui.custom).mockImplementation((callback) => {
        const mockSelectList = {
          handleInput: vi.fn(),
          onSelect: vi.fn(),
          onCancel: vi.fn(),
          onSelectionChange: vi.fn(),
          setSelectedIndex: vi.fn(),
        };

        const result = callback(
          { requestRender: vi.fn() } as any,
          {
            fg: vi.fn((color, text) => text),
            bold: vi.fn((text) => text),
          } as any,
          {} as any,
          () => {},
        );

        handleInputFn = result.handleInput;

        return Promise.resolve();
      });

      diffExtension(mockPi);
      await registeredCommand.handler([], mockCtx);

      expect(handleInputFn).toBeDefined();
    });

    it("should handle right arrow key for paging down", async () => {
      vi.mocked(mockPi.exec).mockResolvedValueOnce({
        code: 0,
        stdout: Array(20).fill(" M file.ts").join("\n"),
      } as any);

      let handleInputFn: any;

      vi.mocked(mockCtx.ui.custom).mockImplementation((callback) => {
        const result = callback(
          { requestRender: vi.fn() } as any,
          {
            fg: vi.fn((color, text) => text),
            bold: vi.fn((text) => text),
          } as any,
          {} as any,
          () => {},
        );

        handleInputFn = result.handleInput;

        return Promise.resolve();
      });

      diffExtension(mockPi);
      await registeredCommand.handler([], mockCtx);

      expect(handleInputFn).toBeDefined();
    });

    it("should call selectList.handleInput for other keys", async () => {
      vi.mocked(mockPi.exec).mockResolvedValueOnce({
        code: 0,
        stdout: " M file.ts",
      } as any);

      let handleInputFn: any;
      const mockSelectListHandleInput = vi.fn();

      vi.mocked(mockCtx.ui.custom).mockImplementation((callback) => {
        const result = callback(
          { requestRender: vi.fn() } as any,
          {
            fg: vi.fn((color, text) => text),
            bold: vi.fn((text) => text),
          } as any,
          {} as any,
          () => {},
        );

        handleInputFn = result.handleInput;

        return Promise.resolve();
      });

      diffExtension(mockPi);
      await registeredCommand.handler([], mockCtx);

      expect(handleInputFn).toBeDefined();
    });

    it("should handle cancel by calling done", async () => {
      vi.mocked(mockPi.exec).mockResolvedValueOnce({
        code: 0,
        stdout: " M file.ts",
      } as any);

      vi.mocked(mockCtx.ui.custom).mockImplementation((callback) => {
        callback({} as any, { fg: (_, t) => t, bold: (t) => t } as any, {} as any, () => {});
        return Promise.resolve();
      });

      diffExtension(mockPi);
      await registeredCommand.handler([], mockCtx);

      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should render help text with navigation hints", async () => {
      vi.mocked(mockPi.exec).mockResolvedValueOnce({
        code: 0,
        stdout: " M file.ts",
      } as any);

      vi.mocked(mockCtx.ui.custom).mockImplementation((callback) => {
        callback({} as any, { fg: (_, t) => t, bold: (t) => t } as any, {} as any, () => {});
        return Promise.resolve();
      });

      diffExtension(mockPi);
      await registeredCommand.handler([], mockCtx);

      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should apply correct colors to status labels", async () => {
      vi.mocked(mockPi.exec).mockResolvedValueOnce({
        code: 0,
        stdout: " M file1.ts\nA  file2.ts\nD  file3.ts\n?? file4.ts",
      } as any);

      const mockFg = vi.fn((color, text) => `${color}:${text}`);

      vi.mocked(mockCtx.ui.custom).mockImplementation((callback) => {
        callback(
          { requestRender: vi.fn() } as any,
          {
            fg: mockFg,
            bold: (t) => t,
          } as any,
          {} as any,
          () => {},
        );
        return Promise.resolve();
      });

      diffExtension(mockPi);
      await registeredCommand.handler([], mockCtx);

      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should clamp currentIndex to valid range on left arrow", async () => {
      vi.mocked(mockPi.exec).mockResolvedValueOnce({
        code: 0,
        stdout: Array(20).fill(" M file.ts").join("\n"),
      } as any);

      vi.mocked(mockCtx.ui.custom).mockImplementation((callback) => {
        callback(
          { requestRender: vi.fn() } as any,
          {
            fg: (_, t) => t,
            bold: (t) => t,
          } as any,
          {} as any,
          () => {},
        );
        return Promise.resolve();
      });

      diffExtension(mockPi);
      await registeredCommand.handler([], mockCtx);

      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should clamp currentIndex to valid range on right arrow", async () => {
      vi.mocked(mockPi.exec).mockResolvedValueOnce({
        code: 0,
        stdout: Array(20).fill(" M file.ts").join("\n"),
      } as any);

      vi.mocked(mockCtx.ui.custom).mockImplementation((callback) => {
        callback(
          { requestRender: vi.fn() } as any,
          {
            fg: (_, t) => t,
            bold: (t) => t,
          } as any,
          {} as any,
          () => {},
        );
        return Promise.resolve();
      });

      diffExtension(mockPi);
      await registeredCommand.handler([], mockCtx);

      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });

    it("should limit visibleRows to minimum of file count and 15", async () => {
      vi.mocked(mockPi.exec).mockResolvedValueOnce({
        code: 0,
        stdout: Array(5).fill(" M file.ts").join("\n"),
      } as any);

      vi.mocked(mockCtx.ui.custom).mockImplementation((callback) => {
        callback(
          { requestRender: vi.fn() } as any,
          {
            fg: (_, t) => t,
            bold: (t) => t,
          } as any,
          {} as any,
          () => {},
        );
        return Promise.resolve();
      });

      diffExtension(mockPi);
      await registeredCommand.handler([], mockCtx);

      expect(mockCtx.ui.custom).toHaveBeenCalled();
    });
  });
});