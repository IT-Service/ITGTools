. $PSScriptRoot\..\_InitializeTests.ps1

Describe 'Add-PrivateFunction' {

  InModuleScope ITGTools {

    Context "When not passed any parameters." {

      It 'Should write correct output.' {
        Add-PrivateFunction | Should Be "Your private function ran!"
      }

    }
  
  }
  
}
