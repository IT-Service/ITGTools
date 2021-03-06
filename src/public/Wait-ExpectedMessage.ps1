﻿Function Wait-ExpectedMessage
{

    <#
    .Synopsis
        Ожидает появления в потоке строки, соответствующей шаблону PromptPattern.
        Генерирует исключение в случае таймаута.
    .Description
        Ожидает появления в потоке строки, соответствующей шаблону PromptPattern.
        Генерирует исключение в случае таймаута.
        Следует использовать до подачи команды на удалённую консоль, чтобы убедиться,
        что консоль готова принимать команды.
        С ключом PassThru возвращает в качестве результата вывод удалённой консоли
        до строки, соответствующей PromptPattern.
    #>

    [CmdletBinding()]

    Param(
        # Шаблон строки, ожидаемой в выводе удалённой консоли
        [Parameter(
            Position = 0
        )]
        [ValidateNotNullOrEmpty()]
        [string] $PromptPattern = '\[.+?\] >',

        # Читатель потока удалённой консоли
        [Parameter(
            Mandatory = $true
        )]
        [ValidateNotNull()]
        [System.IO.TextReader] $ConsoleStreamReader,

        # Ключ, определяющий необходимость возврата вывода удалённой консоли
        [Switch] $PassThru,

        # Таймаут
        [Parameter()]
        [System.TimeSpan] $Timeout = 0
    )

    try
    {

        $Buffer = '';
        $VerboseBuffer = '';

        $Timer = New-Object Diagnostics.StopWatch;
        if ( $Timeout -ne 0 )
        {
            $Timer.Start();
        };

        $RegExp = New-Object System.Text.RegularExpressions.Regex( $PromptPattern );

        do
        {
            $StreamData = $ConsoleStreamReader.Read();
            while ( ( $StreamData -eq -1 ) -and ( $Timer.Elapsed -le $Timeout ) )
            {
                Start-Sleep -Milliseconds 50;
                $StreamData = $ConsoleStreamReader.Read();
            };
            if ( $Timer.Elapsed -gt $Timeout )
            {
                throw ( New-Object System.TimeoutException );
            };
            switch ( [char]$StreamData )
            {
                "`r"
                {
                    if ( $VerboseBuffer )
                    {
                        Write-Verbose $VerboseBuffer;
                        $VerboseBuffer = "";
                    };
                }
                "`n"
                {
                }
                Default
                {
                    $VerboseBuffer += [char] $StreamData;
                }
            }
            $Buffer += [char] $StreamData;
            $SearchResults = $RegExp.Match( $Buffer );
        } while ( -not $SearchResults.Success );

        if ( $VerboseBuffer )
        {
            Write-Verbose $VerboseBuffer;
            $VerboseBuffer = "";
        };

        $Result = $Buffer.Substring( 0, $SearchResults.Index );
        $Buffer = $Buffer.Remove( 0, $SearchResults.Index + $SearchResults.Length );
        if ( $PassThru )
        {
            return $Result;
        };

    }
    catch
    {
        Write-Error -ErrorRecord $_;
    };

}
