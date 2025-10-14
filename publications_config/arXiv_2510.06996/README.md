# arXiv:2510.069966

The XML file `jetscape_user_SMASHInitialCondition_movie.xml` can produce 
hadronic output and hydrodynamic evolution output to create a movie of the
evolution.
The current setting is for a Au+Au collision at 200 GeV with a random impact
parameter between 6 and 8 fm.

The XML file `jetscape_user_SMASHInitialCondition.xml` does not produce
hadronic output and hydrodynamic evolution output, but is otherwise identical.
In the paper we have varied the following parameters:
- Collision energy `IS:SMASH:Sqrtsnn`: (7.7 GeV, 19.6 GeV, 200 GeV)
- Impact parameter:
    - `IS:SMASH:Impact:Mode = 0`: fixed impact parameter with `IS:SMASH:Impact:Value`
    - `IS:SMASH:Impact:Mode = 1`: random impact parameter between `IS:SMASH:Impact:ImpactMin = 6.0` and `IS:SMASH:Impact:Max = 8.0`