﻿. $PSScriptRoot\..\_InitializeTests.ps1

Describe 'Invoke-RemoteCommand' {

    InModuleScope ITGSerialTerminalTools {

        Context "When not passed prompt template." {
            BeforeEach {
                [String] $Command = 'test command';
                [String] $Prompt = '[admin@router] >';
                [String] $TestConsoleOutputContent1 = @"
${Prompt} ${Command}
${Prompt} ${Command}
test result
${Prompt}

"@;
                [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
                    'PSUseDeclaredVarsMoreThanAssignments', '',
                    Scope = 'Function', Target = 'Reader'
                )]
                $Reader = New-Object System.IO.StringReader( $TestConsoleOutputContent1 );
                [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
                    'PSUseDeclaredVarsMoreThanAssignments', '',
                    Scope = 'Function', Target = 'Writer'
                )]
                $Writer = New-Object System.IO.StringWriter;
            }
            It 'Should return correct result.' {
                Invoke-ITGSerialTerminalRemoteCommand `
                    -ConsoleStreamReader $Reader `
                    -ConsoleStreamWriter $Writer `
                    -Command $Command `
                    -Timeout ( New-Object System.TimeSpan( 0, 0, 1 ) ) `
                    -PassThru `
                | Should Be "`r`ntest result`r`n";
            }
            It 'Should write command to console.' {
                Invoke-ITGSerialTerminalRemoteCommand `
                    -ConsoleStreamReader $Reader `
                    -ConsoleStreamWriter $Writer `
                    -Command $Command `
                    -Timeout ( New-Object System.TimeSpan( 0, 0, 1 ) ) `
                    -PassThru;
                $Writer.ToString() | Should Be "${Command}`r`n";
            }
        }

        Context "When console output does not contains prompt template." {
            BeforeEach {
                [String] $Command = 'test command';
                [String] $Prompt = '[admin@router] >';
                [String] $TestConsoleOutputContent1 = @"
${Prompt} ${Command}
${Prompt} ${Command}
test result
${Prompt}

"@;
                [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
                    'PSUseDeclaredVarsMoreThanAssignments', '',
                    Scope = 'Function', Target = 'Reader'
                )]
                $Reader = New-Object System.IO.StringReader( $TestConsoleOutputContent1 );
                [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
                    'PSUseDeclaredVarsMoreThanAssignments', '',
                    Scope = 'Function', Target = 'Writer'
                )]
                $Writer = New-Object System.IO.StringWriter;
            }
            It 'Should throw timeout error.' {
                {
                    Invoke-ITGSerialTerminalRemoteCommand `
                        -ConsoleStreamReader $Reader `
                        -ConsoleStreamWriter $Writer `
                        -Command $Command `
                        -PromptPattern '\[unknownPrompt\] >' `
                        -Timeout ( New-Object System.TimeSpan( 0, 0, 1 ) ) `
                        -PassThru `
                } | Should -Throw
            }
        }

    }

}