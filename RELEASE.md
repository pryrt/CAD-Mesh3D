[![](https://img.shields.io/cpan/v/CAD-Mesh3D.svg?colorB=00CC00 "metacpan")](https://metacpan.org/pod/CAD::Mesh3D)
[![](http://cpants.cpanauthors.org/dist/CAD-Mesh3D.png "cpan testers")](http://matrix.cpantesters.org/?dist=CAD-Mesh3D)
[![](https://img.shields.io/github/release/pryrt/CAD-Mesh3D.svg "github release")](https://github.com/pryrt/CAD-Mesh3D/releases)
[![](https://img.shields.io/github/issues/pryrt/CAD-Mesh3D.svg "issues")](https://github.com/pryrt/CAD-Mesh3D/issues)
[![](https://ci.appveyor.com/api/projects/status/6gv0lnwj1t6yaykp/branch/master?svg=true "build status")](https://ci.appveyor.com/project/pryrt/CAD-Mesh3D)

# Releasing CAD::Mesh3D

This describes some of my methodology for releasing a distribution.  To help with testing, I've integrated the [GitHub repo](https://github.com/pryrt/CAD-Mesh3D/)
with [AppVeyor CI](https://ci.appveyor.com/project/pryrt/cad-mesh3d) and [Travis CI](https://travis-ci.org/github/pryrt/CAD-Mesh3D).

## My Methodology

I use a local svn client to checkout the GitHub repo.  All these things can be done with a git client, but the terminology changes, and I cease being comfortable.

* **Development:**

    * **GitHub:** create a branch

    * **svn:** switch from trunk to branch

    * `prove -l t` for normal tests, `prove -l xt` for author tests
    * use `berrybrew exec` or `perlbrew exec` on those `prove`s to get a wider suite
    * every `svn commit` to the GitHub repo should trigger AppVeyor build suite

* **Release:**

    * Verify perl v5.10: that isn't covered in appveyor

    * Verify dos8.3-style shortnames:               # shortname cannot be auto-tested (easily?) in appveyor
        * dir .. /X                                 # list the shortname for parent directory
        * cd ..\short8.3                            # force cmd.exe to use shortname notation
        * `prove -l t`                              # ensure it still works in shortname mode

    * **Verify Documentation:**
        * make sure versioning is correct
        * verify README.md is up-to-date
            * `dmake README.md` or `gmake README.md`
            * or `dmake docs` or `gmake docs`
        * verify CHANGES (history)

    * **Build Distribution**

            gmake veryclean                         # clear out all the extra junk
            perl Makefile.PL                        # create a new makefile
            gmake                                   # copy the library to ./blib/lib...
            gmake distcheck                         # check for new or removed files
            gmake manifest                          # if this steps adds or deletes incorrectly, please fix MANIFEST.SKIP ; MANIFEST is auto-generated
            gmake disttest                          # optional, if you want to verify that make test will work for the CPAN audience
            set MM_SIGN_DIST=1                      # enable signatures for build
            set TEST_SIGNATURE=1                    # verify signatures during `disttest`
            perl Makefile.PL && gmake distauthtest  # recreate Makefile and re-run distribution test with signing & test-signature turned on
            set TEST_SIGNATURE=                     # clear signature verification during `disttest`
            gmake dist                              # actually make the tarball
            gmake veryclean                         # clean out this directory
            set MM_SIGN_DIST=                       # clear signatures after build

    * **svn:** final commit of the development branch

    * **svn:** switch back to trunk (master) repo

    * **GitHub:** make a pull request to bring the branch back into the trunk
        * This should trigger AppVeyor approval for the pull request
        * Once AppVeyor approves, need to approve the pull request, then the branch will be merged back into the trunk
        * If that branch is truly done, delete the branch using the pull-request page (wait until AFTER `svn switch`, otherwise `svn switch` will fail)

    * **GitHub:** [create a new release](https://help.github.com/articles/creating-releases/):
        * Releases > Releases > Draft a New Release
        * tag name = `v#.###`
        * release title = `v#.###`

    * **PAUSE:** [upload distribution tarball to CPAN/PAUSE](https://pause.perl.org/pause/authenquery?ACTION=add_uri) by browsing to the file on my computer.
        * Watch <https://metacpan.org/author/PETERCJ> and <http://search.cpan.org/~petercj/> for when it updates
        * Watch CPAN Testers

    * **GitHub:** Clear out any [issues](https://github.com/pryrt/Win32-Mechanize-NotepadPlusPlus/issues/) that were resolved by this release

