const std = @import("std");
const Token = @import("../token/Token.zig");

const TokenType = Token.TokenType;

const Self = @This();

input: []const u8,
position: usize,
read_position: usize,
ch: u8,

pub fn init(input: []const u8) Self {
    var output = Self{
        .input = input,
        .position = 0,
        .read_position = 0,
        .ch = 0,
    };
    output.readChar();
    return output;
}

pub fn nextToken(self: *Self) Token {
    self.skipWhitespace();

    const token = switch (self.ch) {
        '=' => blk: {
            if (self.peekChar() == '=') {
                const pos = self.position;
                self.readChar();
                const literal = self.input[pos..self.read_position];
                break :blk Token{ .type = TokenType.EQ, .literal = literal };
            } else {
                break :blk Token{ .type = TokenType.ASSIGN, .literal = "=" };
            }
        },
        '!' => blk: {
            if (self.peekChar() == '=') {
                const pos = self.position;
                self.readChar();
                const literal = self.input[pos..self.read_position];
                break :blk Token{ .type = TokenType.NOT_EQ, .literal = literal };
            } else {
                break :blk Token{ .type = TokenType.BANG, .literal = "!" };
            }
        },
        inline '+', '-', '/', '*', '<', '>', ';', ',', '{', '}', '(', ')' => |ch| newToken(ch),
        0 => Token{ .type = TokenType.EOF, .literal = "" },
        else => {
            if (isLetter(self.ch)) {
                const literal = self.readIdentifier();
                return Token{ .type = Token.lookUpIdent(literal), .literal = literal };
            } else if (isDigit(self.ch)) {
                return Token{ .type = TokenType.INT, .literal = self.readNumber() };
            } else {
                return Token{ .type = TokenType.ILLEGAL, .literal = self.input[self.position..self.read_position] };
            }
        },
    };

    self.readChar();
    return token;
}

fn skipWhitespace(self: *Self) void {
    while (self.ch == ' ' or self.ch == '\t' or self.ch == '\n' or self.ch == '\r') {
        self.readChar();
    }
}

fn readChar(self: *Self) void {
    if (self.read_position >= self.input.len) {
        self.ch = 0;
    } else {
        self.ch = self.input[self.read_position];
    }
    self.position = self.read_position;
    self.read_position += 1;
}

fn peekChar(self: *Self) u8 {
    if (self.read_position >= self.input.len) {
        return 0;
    }
    return self.input[self.read_position];
}

fn readIdentifier(self: *Self) []const u8 {
    const position = self.position;
    while (isLetter(self.ch)) {
        self.readChar();
    }
    return self.input[position..self.position];
}

fn readNumber(self: *Self) []const u8 {
    const position = self.position;
    while (isDigit(self.ch)) {
        self.readChar();
    }
    return self.input[position..self.position];
}

fn isLetter(ch: u8) bool {
    return ('a' <= ch and ch <= 'z') or ('A' <= ch and ch <= 'Z') or (ch == '_');
}

fn isDigit(ch: u8) bool {
    return '0' <= ch and ch <= '9';
}

fn newToken(comptime ch: u8) Token {
    return switch (ch) {
        '+' => .{ .type = TokenType.PLUS, .literal = "+" },
        '-' => .{ .type = TokenType.MINUS, .literal = "-" },
        '/' => .{ .type = TokenType.SLASH, .literal = "/" },
        '*' => .{ .type = TokenType.ASTERISK, .literal = "*" },
        '<' => .{ .type = TokenType.LT, .literal = "<" },
        '>' => .{ .type = TokenType.GT, .literal = ">" },
        ';' => .{ .type = TokenType.SEMICOLON, .literal = ";" },
        ',' => .{ .type = TokenType.COMMA, .literal = "," },
        '{' => .{ .type = TokenType.LBRACE, .literal = "{" },
        '}' => .{ .type = TokenType.RBRACE, .literal = "}" },
        '(' => .{ .type = TokenType.LPAREN, .literal = "(" },
        ')' => .{ .type = TokenType.RPAREN, .literal = ")" },
        else => @compileError(std.fmt.comptimePrint("Given token `{c}` is not valid", .{ch})),
    };
}
