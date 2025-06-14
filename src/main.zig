const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;

const CalcError = error{
    InvalidOperation,
    DivisionByZero,
    ParseError,
    InvalidExpression,
};

fn parseNumber(input: []const u8) !f64 {
    const trimmed = std.mem.trim(u8, input, " \t\n\r");
    return std.fmt.parseFloat(f64, trimmed) catch CalcError.ParseError;
}

fn calculate(a: f64, op: u8, b: f64) !f64 {
    return switch (op) {
        '+' => a + b,
        '-' => a - b,
        '*' => a * b,
        '/' => {
            if (b == 0) return CalcError.DivisionByZero;
            return a / b;
        },
        '%' => {
            if (b == 0) return CalcError.DivisionByZero;
            return @mod(a, b);
        },
        '^' => std.math.pow(f64, a, b),
        else => CalcError.InvalidOperation,
    };
}

fn parseExpression(input: []const u8) !struct { f64, u8, f64 } {
    // Find the operator
    var op_pos: ?usize = null;
    var operator: u8 = 0;

    // Look for operators (skip first character to allow negative numbers)
    for (input[1..], 1..) |char, i| {
        if (char == '+' or char == '-' or char == '*' or char == '/' or char == '%' or char == '^') {
            op_pos = i;
            operator = char;
            break;
        }
    }

    if (op_pos == null) {
        return CalcError.InvalidExpression;
    }

    const num1_str = input[0..op_pos.?];
    const num2_str = input[op_pos.? + 1 ..];

    const num1 = try parseNumber(num1_str);
    const num2 = try parseNumber(num2_str);

    return .{ num1, operator, num2 };
}

fn printWelcome() void {
    print("\n=== Interactive Calculator ===\n", .{});
    print("Enter expressions like: 10 + 5, 20 / 4, 7 * 3\n", .{});
    print("Supported operators: +, -, *, /, %% (modulo), ^ (power)\n", .{});
    print("Commands: 'help' for this message, 'quit' or 'exit' to quit\n", .{});
    print("==========================================\n\n", .{});
}

fn printHelp() void {
    print("\nCalculator Help:\n", .{});
    print("  Basic operations: 10 + 5, 20 - 3, 7 * 8, 15 / 3\n", .{});
    print("  Modulo: 17 %% 5 (remainder of division)\n", .{});
    print("  Power: 2 ^ 3 (2 to the power of 3)\n", .{});
    print("  Decimals supported: 3.14 * 2\n", .{});
    print("  Negative numbers: -5 + 10\n", .{});
    print("  Commands: 'help', 'quit', 'exit'\n\n", .{});
}

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    var buffer: [256]u8 = undefined;

    printWelcome();

    while (true) {
        print("> ", .{});

        // Read user input
        if (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |input| {
            const trimmed_input = std.mem.trim(u8, input, " \t\n\r");

            // Handle empty input
            if (trimmed_input.len == 0) {
                continue;
            }

            // Handle commands
            if (std.mem.eql(u8, trimmed_input, "quit") or std.mem.eql(u8, trimmed_input, "exit")) {
                print("Goodbye!\n", .{});
                break;
            }

            if (std.mem.eql(u8, trimmed_input, "help")) {
                printHelp();
                continue;
            }

            // Parse and calculate expression
            const expression = parseExpression(trimmed_input) catch |err| {
                switch (err) {
                    CalcError.InvalidExpression => print("Error: Invalid expression. Use format: number operator number\n", .{}),
                    CalcError.ParseError => print("Error: Invalid number format\n", .{}),
                    else => print("Error: Failed to parse expression\n", .{}),
                }
                continue;
            };

            const result = calculate(expression[0], expression[1], expression[2]) catch |err| {
                switch (err) {
                    CalcError.DivisionByZero => print("Error: Division by zero\n", .{}),
                    CalcError.InvalidOperation => print("Error: Invalid operator. Use +, -, *, /, %%, or ^\n", .{}),
                    else => print("Error: Calculation failed\n", .{}),
                }
                continue;
            };

            print("= {d}\n\n", .{result});
        } else {
            // EOF reached (Ctrl+D)
            print("\nGoodbye!\n", .{});
            break;
        }
    }
}
