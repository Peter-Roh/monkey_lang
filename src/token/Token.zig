const std = @import("std");
const StaticStringMap = @import("std").StaticStringMap;

pub const TokenType = enum(u8) {
    ILLEGAL,
    EOF,
    IDENT,
    INT,
    ASSIGN,
    PLUS,
    MINUS,
    BANG,
    ASTERISK,
    SLASH,
    LT,
    GT,
    EQ,
    NOT_EQ,
    COMMA,
    SEMICOLON,
    LPAREN,
    RPAREN,
    LBRACE,
    RBRACE,
    FUNCTION,
    LET,
    TRUE,
    FALSE,
    IF,
    ELSE,
    RETURN,
};
const Keyword = struct {
    key: []const u8,
    value: TokenType,
};

type: TokenType,
literal: []const u8,

const KeywordKV = struct { []const u8, TokenType };
const keywords = StaticStringMap(TokenType).initComptime([_]KeywordKV{
    .{ "fn", TokenType.FUNCTION },
    .{ "let", TokenType.LET },
    .{ "true", TokenType.TRUE },
    .{ "false", TokenType.FALSE },
    .{ "if", TokenType.IF },
    .{ "else", TokenType.ELSE },
    .{ "return", TokenType.RETURN },
});

pub fn lookUpIdent(ident: []const u8) TokenType {
    return keywords.get(ident) orelse TokenType.IDENT;
}
