const std = @import("std");
const monkey_lang = @import("monkey_lang");

const Token = monkey_lang.Token;
const Lexer = monkey_lang.Lexer;

const TokenType = Token.TokenType;

test "NextToken" {
    const input =
        \\ let five = 5;
        \\ let ten = 10;
        \\ let add = fn(x, y) {
        \\   x + y;
        \\ };
        \\
        \\let result = add(five, ten);
        \\ !-/*5;
        \\ 5 < 10 > 5;
        \\ if (5 < 10) {
        \\   return true;
        \\ } else {
        \\   return false;
        \\ }
        \\
        \\ 10 == 10;
        \\ 10 != 9;
    ;

    const Test = struct {
        expected_type: TokenType,
        expected_literal: []const u8,
    };
    const tests = [_]Test{
        Test{ .expected_type = TokenType.LET, .expected_literal = "let" },
        Test{ .expected_type = TokenType.IDENT, .expected_literal = "five" },
        Test{ .expected_type = TokenType.ASSIGN, .expected_literal = "=" },
        Test{ .expected_type = TokenType.INT, .expected_literal = "5" },
        Test{ .expected_type = TokenType.SEMICOLON, .expected_literal = ";" },
        Test{ .expected_type = TokenType.LET, .expected_literal = "let" },
        Test{ .expected_type = TokenType.IDENT, .expected_literal = "ten" },
        Test{ .expected_type = TokenType.ASSIGN, .expected_literal = "=" },
        Test{ .expected_type = TokenType.INT, .expected_literal = "10" },
        Test{ .expected_type = TokenType.SEMICOLON, .expected_literal = ";" },
        Test{ .expected_type = TokenType.LET, .expected_literal = "let" },
        Test{ .expected_type = TokenType.IDENT, .expected_literal = "add" },
        Test{ .expected_type = TokenType.ASSIGN, .expected_literal = "=" },
        Test{ .expected_type = TokenType.FUNCTION, .expected_literal = "fn" },
        Test{ .expected_type = TokenType.LPAREN, .expected_literal = "(" },
        Test{ .expected_type = TokenType.IDENT, .expected_literal = "x" },
        Test{ .expected_type = TokenType.COMMA, .expected_literal = "," },
        Test{ .expected_type = TokenType.IDENT, .expected_literal = "y" },
        Test{ .expected_type = TokenType.RPAREN, .expected_literal = ")" },
        Test{ .expected_type = TokenType.LBRACE, .expected_literal = "{" },
        Test{ .expected_type = TokenType.IDENT, .expected_literal = "x" },
        Test{ .expected_type = TokenType.PLUS, .expected_literal = "+" },
        Test{ .expected_type = TokenType.IDENT, .expected_literal = "y" },
        Test{ .expected_type = TokenType.SEMICOLON, .expected_literal = ";" },
        Test{ .expected_type = TokenType.RBRACE, .expected_literal = "}" },
        Test{ .expected_type = TokenType.SEMICOLON, .expected_literal = ";" },
        Test{ .expected_type = TokenType.LET, .expected_literal = "let" },
        Test{ .expected_type = TokenType.IDENT, .expected_literal = "result" },
        Test{ .expected_type = TokenType.ASSIGN, .expected_literal = "=" },
        Test{ .expected_type = TokenType.IDENT, .expected_literal = "add" },
        Test{ .expected_type = TokenType.LPAREN, .expected_literal = "(" },
        Test{ .expected_type = TokenType.IDENT, .expected_literal = "five" },
        Test{ .expected_type = TokenType.COMMA, .expected_literal = "," },
        Test{ .expected_type = TokenType.IDENT, .expected_literal = "ten" },
        Test{ .expected_type = TokenType.RPAREN, .expected_literal = ")" },
        Test{ .expected_type = TokenType.SEMICOLON, .expected_literal = ";" },
        Test{ .expected_type = TokenType.BANG, .expected_literal = "!" },
        Test{ .expected_type = TokenType.MINUS, .expected_literal = "-" },
        Test{ .expected_type = TokenType.SLASH, .expected_literal = "/" },
        Test{ .expected_type = TokenType.ASTERISK, .expected_literal = "*" },
        Test{ .expected_type = TokenType.INT, .expected_literal = "5" },
        Test{ .expected_type = TokenType.SEMICOLON, .expected_literal = ";" },
        Test{ .expected_type = TokenType.INT, .expected_literal = "5" },
        Test{ .expected_type = TokenType.LT, .expected_literal = "<" },
        Test{ .expected_type = TokenType.INT, .expected_literal = "10" },
        Test{ .expected_type = TokenType.GT, .expected_literal = ">" },
        Test{ .expected_type = TokenType.INT, .expected_literal = "5" },
        Test{ .expected_type = TokenType.SEMICOLON, .expected_literal = ";" },
        Test{ .expected_type = TokenType.IF, .expected_literal = "if" },
        Test{ .expected_type = TokenType.LPAREN, .expected_literal = "(" },
        Test{ .expected_type = TokenType.INT, .expected_literal = "5" },
        Test{ .expected_type = TokenType.LT, .expected_literal = "<" },
        Test{ .expected_type = TokenType.INT, .expected_literal = "10" },
        Test{ .expected_type = TokenType.RPAREN, .expected_literal = ")" },
        Test{ .expected_type = TokenType.LBRACE, .expected_literal = "{" },
        Test{ .expected_type = TokenType.RETURN, .expected_literal = "return" },
        Test{ .expected_type = TokenType.TRUE, .expected_literal = "true" },
        Test{ .expected_type = TokenType.SEMICOLON, .expected_literal = ";" },
        Test{ .expected_type = TokenType.RBRACE, .expected_literal = "}" },
        Test{ .expected_type = TokenType.ELSE, .expected_literal = "else" },
        Test{ .expected_type = TokenType.LBRACE, .expected_literal = "{" },
        Test{ .expected_type = TokenType.RETURN, .expected_literal = "return" },
        Test{ .expected_type = TokenType.FALSE, .expected_literal = "false" },
        Test{ .expected_type = TokenType.SEMICOLON, .expected_literal = ";" },
        Test{ .expected_type = TokenType.RBRACE, .expected_literal = "}" },
        Test{ .expected_type = TokenType.INT, .expected_literal = "10" },
        Test{ .expected_type = TokenType.EQ, .expected_literal = "==" },
        Test{ .expected_type = TokenType.INT, .expected_literal = "10" },
        Test{ .expected_type = TokenType.SEMICOLON, .expected_literal = ";" },
        Test{ .expected_type = TokenType.INT, .expected_literal = "10" },
        Test{ .expected_type = TokenType.NOT_EQ, .expected_literal = "!=" },
        Test{ .expected_type = TokenType.INT, .expected_literal = "9" },
        Test{ .expected_type = TokenType.SEMICOLON, .expected_literal = ";" },
        Test{ .expected_type = TokenType.EOF, .expected_literal = "" },
    };

    var lexer = Lexer.init(input);

    for (tests, 0..) |t, i| {
        const token = lexer.nextToken();

        if (!std.mem.eql(u8, token.literal, t.expected_literal)) {
            std.debug.print("tests[{d}]: literal wrong. expected {s} got {s}\n", .{ i, t.expected_literal, token.literal });
        }

        try std.testing.expect(token.type == t.expected_type);
        try std.testing.expect(std.mem.eql(u8, token.literal, t.expected_literal));
    }
}
