const std = @import("std");
const c = @import("c");
const hash = std.crypto.hash;
const Sha1 = std.crypto.hash.Sha1;
const sha2 = std.crypto.hash.sha2;
const Md5 = std.crypto.hash.Md5;

const Mapping = union(enum) {
    MD5: hash.Md5,
    SHA1: hash.Sha1,
    SHA224: hash.sha2.Sha224,
    SHA256: hash.sha2.Sha256,
    SHA384: hash.sha2.Sha384,
    SHA512: hash.sha2.Sha512,
    SHA512_256: hash.sha2.Sha512_256,
};

comptime {
    for (@typeInfo(Mapping).@"union".fields) |field| {
        const ctx_name = field.name ++ "_CTX";
        const Ctx = if (@hasDecl(c, ctx_name))
            @field(c, field.name ++ "_CTX")
        else
            @field(c, "SHA2_CTX");

        const RealCtx = field.type;
        @export(&(struct {
            fn init(ctx: [*c]Ctx) callconv(.c) void {
                const ptr: *RealCtx = @ptrCast(@alignCast(ctx));
                ptr.* = .init(.{});
            }
        }).init, .{ .name = field.name ++ "Init" });
        @export(&(struct {
            fn update(ctx: [*c]Ctx, input: [*c]const u8, len: usize) callconv(.c) void {
                const ptr: *RealCtx = @ptrCast(@alignCast(ctx));
                ptr.update(input[0..len]);
            }
        }).update, .{ .name = field.name ++ "Update" });
        @export(&(struct {
            fn final(digest: [*c]u8, ctx: [*c]Ctx) callconv(.c) void {
                const ptr: *RealCtx = @ptrCast(@alignCast(ctx));
                ptr.final(digest[0..RealCtx.digest_length]);
            }
        }).final, .{ .name = field.name ++ "Final" });
        @export(&(struct {
            fn pad(ctx: [*c]Ctx) callconv(.c) void {
                _ = ctx;
                @panic("unimplemented");
            }
        }).pad, .{ .name = field.name ++ "Pad" });
        @export(&(struct {
            fn transform(state: [*c]u32, ctx: [*c]const u8) callconv(.c) void {
                _ = state;
                _ = ctx;
                @panic("unimplemented");
            }
        }).transform, .{ .name = field.name ++ "Transform" });
        @export(&(struct {
            fn end(ctx: [*c]Ctx, buf: [*c]u8) callconv(.c) [*c]u8 {
                _ = ctx;
                _ = buf;
                @panic("unimplemented");
            }
        }).end, .{ .name = field.name ++ "End" });
        @export(&(struct {
            fn file(filename: [*c]const u8, buf: [*c]u8) callconv(.c) [*c]u8 {
                _ = filename;
                _ = buf;
                @panic("unimplemented");
            }
        }).file, .{ .name = field.name ++ "File" });
        @export(&(struct {
            fn fileChunk(filename: [*c]const u8, buf: [*c]u8, off: c.off_t, len: c.off_t) callconv(.c) [*c]u8 {
                _ = filename;
                _ = buf;
                _ = off;
                _ = len;
                @panic("unimplemented");
            }
        }).fileChunk, .{ .name = field.name ++ "FileChunk" });
        @export(&(struct {
            fn data(d: [*c]const u8, len: usize, buf: [*c]u8) callconv(.c) [*c]u8 {
                _ = d;
                _ = len;
                _ = buf;
                @panic("unimplemented");
            }
        }).data, .{ .name = field.name ++ "Data" });
    }
}
