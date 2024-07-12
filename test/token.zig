const std = @import("std");
const monkey_lang = @import("monkey_lang");

const Token = monkey_lang.Token;
const TokenType = Token.TokenType;

test "LookupIdent proper case" {
    const ident = "let";
    const token_type = Token.lookUpIdent(ident);
    try std.testing.expect(token_type == TokenType.LET);
}

test "LookupIdent unknown case" {
    const ident_unknown = "unknown";
    const token_type_unknown = Token.lookUpIdent(ident_unknown);
    try std.testing.expect(token_type_unknown == TokenType.IDENT);
}
