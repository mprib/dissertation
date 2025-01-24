Study 3: Characterize adaptations to bilateral Phase-Dependent Speed Variation in healthy subjects.
===================================================================================================

Introduction
------------

In elderly individuals, slower walking speeds are associated with an
increased risk of falls (Bergen, Stevens, and Burns 2016) and death
(Hardy et al. 2007). Decreases in walking speed with age can be
predicted by increases in the metabolic cost of walking as individuals
age(Schrack et al. 2012). One of the primary contributors to an
increasing metabolic cost of walking as individuals age is the tendency
to decrease ankle plantarflexion (PF) joint torques and increase hip
joint torques throughout the gait cycle(Delabastita et al. 2021). This
"proximal shift" in joint torques is one of the hallmarks of aging gait
(DeVita and Hortobagyi 2000; Kerrigan et al. 1998; Silder, Heiderscheit,
and Thelen 2008). An intervention capable of reversing this proximal
shift by increasing PF torque during gait may cultivate a more efficient
gait pattern that disrupts the trajectory of decreased walking economy,
decreased walking speeds, and increased mortality.

While simply walking faster can increase ankle PF demands in older
adults (Silder, Heiderscheit, and Thelen 2008), it does not specifically
address the inefficient gait patterns at a person's typical
self-selected speed or the tendency of older adults adopt a faster
cadence than younger adults at a given speed(Nagasaki et al. 1996), a
strategy that reduces mechanical demands at the ankle at the expense of
increased demands at the hip(Umberger and Martin 2007).

Walking on a Split Belt Treadmill (SBT) with belts moving at different
speeds has been shown to evoke spontaneous adaptations in PF torque that
persist temporarily when the belts return to matched speeds (Lauziare et
al. 2014). These changes in PF torque correlate with the changes in step
length(Lauziare et al. 2014) that are typically observed following
adaptation to a SBT(Reisman, Block, and Bastian 2005; Reisman et al.
2007) and are driven by feedforward cerebellar control mechanisms
(Morton and Bastian 2006).

By its nature, the SBT task is asymmetrical. Shorter steps on the
slow-belt side correspond with smaller peak PF torque on the fast-belt
side; longer steps on the fast-belt side correspond with larger peak PF
torque on the slow-belt side.

In Study 2, we introduced Phase Dependent Speed Variation (PDSV) as a
tool to decompose the perturbations of a conventional SBT (cSBT) into
two distinct components:

1.  FastBrake (stepping *onto* a faster belt): the leading limb
    generates braking force while it is *pushed toward* the slower
    moving trailing limb.

2.  FastProp (stepping *off of* a faster belt): the trailing limb
    generates propulsive force while being *pulled away* from the slower
    leading limb.

This decomposition is achieved by varying the target belt speed based on
event triggers associated with the vertical Ground Reaction Force (GRF)
under each limb. FastBrake (or FastProp) can be implemented by detecting
when a limb leaves the belt to begin swing, triggering the belt to speed
up (or slow down); after the limb touches down and begins to bear more
vertical GRF than the opposite limb, the belt will slow down (or speed
up).

![](bil_media/media/image1.png){width="4.642361111111111in"
height="2.7597222222222224in"}Unlike a cSBT, these components can be
applied bilaterally. For bilateral FastBrake, the leading limb is always
pushed toward the trailing limb. In bilateral FastProp, the trailing
limb is always pulled away from the leading limb. Example belt speed
profiles of this are shown in Figure 9.

We expect that such a bilateral implementation will evoke changes in PF
torque like those of study 2. Specifically, we hypothesize that
bilateral FastBrake will result in adaptations that bilaterally decrease
PF impulse and FastProp will result in a bilateral increase in PF
impulse.

Methods
-------

The methods of Study 3 will parallel those of Study 2, with the data
collection occurring on the same day with the same subjects. The two
conditions associated with Study 3 will be randomized along with those
of Study 2.

### Participants

We will recruit 20 healthy adults (18-45 years) from central Texas.
Inclusion criteria: ability to walk unassisted for 20 minutes. Exclusion
criteria: pregnancy, lower extremity orthopedic, neurological, vascular,
or metabolic conditions affecting gait.

### Data Collection

We will use a 10-camera Vicon Nexus motion capture system (100 Hz) and
an instrumented split-belt treadmill with handrails (Motek Medical, 1000
Hz). Participants will wear a safety harness, and a 7-segment lower body
marker set. Static and dynamic calibration trials will be performed,
including functional calibration of hip and knee joints using \"hula
hoop\" and \"quarter squat\" movements ^38^.

### Protocol

Participants will complete 2 randomized trials (Bilateral FastBrake,
Bilateral FastProp) as outlined in Table 1. These will be randomized
along with three additional conditions as outlined in Study 2.

*Table 1: Randomly ordered trials in Study 3 (Study 2 Trials in faded
font)*

  **Randomly Ordered Trials**                          
  ----------------------------- ---------------------- -----------------------------------------------------------------------------------------------------------------
  **Study**                     **Condition**          **Description**
  2                             cSBT                   Left belt at 1 m/s and right belt at 2 m/s
  2                             Unilateral FastBrake   Left belt runs 2 m/s at left foot contact, then slows to 1 m/s beginning after weight shift is 50% complete
  2                             Unilateral FastProp    Left belt runs 1 m/s at left foot contact, then increases to 2 m/s beginning after weight shift is 50% complete
  3                             Bilateral FastBrake    Belts run 2 m/s at foot contact, then slow to 1 m/s beginning after weight shift is 50% complete
  3                             Bilateral FastProp     Belts runs 1 m/s at foot contact, then increase to 2 m/s beginning after weight shift is 50% complete

![](bil_media/media/image2.png){width="4.738888888888889in"
height="3.026388888888889in"}![](bil_media/media/image2.png){width="4.738888888888889in"
height="3.026388888888889in"}Each trial consists of 3 minutes baseline
walking (1 m/s), 6 minutes perturbed walking, and 3 minutes
post-adaptation (Figure 10). This protocol structure aligns with
previous research demonstrating detectable changes in PF torque
following Adaptation^36^. We employ a 2:1 speed ratio. In cSBT walking,
this can be largely adapted to within approximately 25 strides ^31^.
Given typical stride times are less than 1.5 seconds each^39^ , our
6-minute adaptation period should allow ample time for full adaptation,
with 3 minutes sufficient for subsequent washout.

Participants will wear a safety harness and receive verbal countdowns
before speed changes. Ground reaction forces will be recorded, and
D-Flow software (v3.20.0) will control belt speeds based on vertical
GRF. Rating of Perceived Exertion (RPE) will be collected using a Borg
RPE 10-point scale ^40^ during the final minute of Baseline and
Adaptation. 60-second recordings will capture late baseline/early
adaptation and late adaptation/early post-adaptation transitions.
Handrails will be available if needed, though participants will be asked
to avoid their use unless necessary to preserve balance.

### Split Belt Control Mechanism

For PDSV trials, custom D-Flow scripts will trigger belt speed changes
based on force plate data: at swing initiation when GRF goes to zero and
then again when the vertical GRF exceeds the contralateral vertical GRF.
The baseline speed is 1 m/s, and the fast speed is 2 m/s, with
transitions limited by the M-Gait\'s maximum belt acceleration of 3
m/s^2^. The resulting belt speed profile then becomes synchronized to
the participant's gait cycle and changes in real time to any alterations
in cadence (Figure 9).

### Rationale for Target Belt Speeds

Healthy individuals walking at ≥1 m/s have a swing time of roughly
one-third of a second ^39^, allowing a 1 m/s speed change during single
limb stance when the belt speed acceleration is 3 m/s^2^. This allows
for a roughly even distribution of fast and baseline speeds across the
braking and propulsive phases of stance (Figure 9). The 2:1 speed ratio
(1 m/s slow, 2 m/s fast) is well-tolerated in healthy individuals during
cSBT walking^31^ and elicits detectable after-effects in ankle joint
torque^36^.

### Data Processing

Visual3D (HAS Motion, Kingston, Ontario) software will perform data
filtering and biomechanical calculations. Marker trajectories and GRF
will be smoothed using second-order Butterworth low-pass filters at 6
Hz. Center of Pressure data will be smoothed using second-order
Butterworth filters at 4 Hz. This lower frequency filter removes an
oscillatory artifact in the treadmill's COP data that is present during
early stance across all trials, including baseline walking. With this
filtering, progression of COP across the foot aligns with typical
patterns of progression^41^. Joint centers will be defined by malleoli
markers (ankle) and functional calibration methods (hip and knee)^38^.

![](bil_media/media/image3.png){width="4.247916666666667in"
height="2.6256944444444446in"}Joint torques will be normalized to body
weight. Joint torque profiles across stance phase will be
time-normalized and averaged across five steps to characterize torque in
each Period (Figure 4). PF impulse will calculated by summing across the
time-normalized joint torque profile when there is a net PF moment, and
then multiplying by the mean stance time to remove the time
normalization.

Actual belt velocity will be calculated using reflective markers affixed
to the belts and custom Python scripts within Vicon. Onset and
completion of the Adaptation period will be identified by this belt
velocity. Primary Variables for Late Baseline and Early Post Adaptation
will be characterized by averaging the last 5 complete steps of Baseline
and first 5 complete steps of Post Adaptation, respectively. Secondary
variables for Early and Late Adaptation will be similarly calculated.

### Primary Variable

**Ankle PF impulse during stance**. Left and right sides will be
averaged. Values will be normalized to body weight; thus units will be
N.m.s/BW.

### Secondary Variables

RPE will be assessed in the final minute of each baseline and adaptation
period.

Lower extremity joint torques will be calculated for all four periods
(Late Baseline, Early Adaptation, Late Adaptation, Early Post
Adaptation).

### Hypothesis

(H1) *Ankle PF Impulse*: Main effect for Period and interaction effect
for Condition and Period. FastProp will increase ankle PF impulse from
Baseline to Post Adaptation, while FastBrake will decrease it.

![](bil_media/media/image4.png){width="4.01875in"
height="2.170138888888889in"}A graphical depiction of the expected
outcomes on primary variables is shown in Figure 12.

These findings would suggest that bilateral PDSV can modulate PF impulse
during symmetrical gait. This may be achieved via a similar
cerebellar-mediated feedforward control mechanism that is responsible
for gait adaptations when walking on a cSBT.

### Statistical Analysis

*Hypothesis Testing*

To assess the effects of the different split-belt treadmill protocols on
primary variables, we will employ a linear mixed-effects model. Mean PF
impulse will be analyzed across Periods (Baseline and Post-Adaptation)
and Conditions (Bilateral FastBrake, and Bilateral FastProp). The model
will include fixed effects for Period and Condition as well as their
interaction. A random intercept for Participant will be included to
account for within-subject variability.

Pairwise comparisons of periods within each condition will be used to
assess each specific intervention, applying Holm\'s correction for
multiple comparisons.

All analyses will be performed in R, using the lme4 package for
mixed-effects modeling and the emmeans package for post-hoc comparisons.
Statistical significance will be set at α = 0.05 for all tests.

*Assessing Potential Confounds*

To assess potential order effects and carryover effects, we will use a
mixed-effects model with condition order and previous condition as fixed
effects and participant as a random effect in predicting mean PF impulse
in the bilateral conditions.

If significant order effects or carryover effects are detected, we will
adjust our primary analysis strategy to include condition order and/or
previous condition as a fixed effect.

*Alternative Outcomes*

If expected changes are not observed, we will examine differences in
gait parameters during late adaptation to potentially explain variations
in post-adaptation PF impulse. Potential compensatory mechanisms include
(a) increased cadence to avoid peak FastProp times and (b) increased hip
flexor torque to substitute for PF torque in facilitating limb swing.

Additionally, participant specific factors will be examined that may
differentiate individuals who respond in an unexpected manner, pointing
toward protocol improvements. For example, shorter-legged individuals
may have trouble with the speed settings suggesting that a more
individualized set of parameters should be used.

Preliminary Results
-------------------

Data for 5 participants has been analyzed.

### Ankle Torque Profiles

Examining the time normalized joint torques averaged across all subjects
suggests a consistent effect like the one observed in Subject 1 in
Figure 11. Upon returning to a steady 1 m/s belt speed following
adaptation to the bilateral FastBrake condition, subjects on average
exhibit an increase in early stance net PF torque and a decrease in late
stance PF torque (Figure 13). This Post Adaptation torque profile stands
in contrast to the curve following bilateral FastProp where there is a
more marked increase in net PF torque beginning in early stance and
extending to approximately 75% of stance.

![A graph with lines and numbers Description automatically
generated](bil_media/media/image5.png){width="4.487615923009624in"
height="2.773912948381452in"}

Figure 13: Joint torque across stance, average across all participants

### Ankle Plantarflexor Impulse

In Figure 14, the mean PF impulse across measurement periods is shown
for each participant. Following Bilateral FastBrake, the impulse
decreases from 0.40 to .36 N.m.s/BW. The impulse increases following
adaptation to Bilateral FastProp from 0.41 to 0.50 N.m.s/BW.

![A graph with lines and dots Description automatically generated with
medium
confidence](bil_media/media/image6.png){width="4.706824146981627in"
height="2.9094116360454945in"}

Figure 14: Plantarflexor impulse across stance (average across sides for
each participant). Dotted lines connect overall mean for each
Condition-Period.

Power Analysis
--------------

Given the planned statistical analysis via linear mixed effects models,
power analysis was performed employing Monte Carlo simulation
techniques(Landau and Stahl 2013) within R. Data was simulated based on
estimates derived from the mean and standard deviations of the 5
preliminary participants. Random samples of varying sizes were drawn
from this simulated data and analyzed via the planned statistical
methods. 500 simulations were performed across a range of sample sizes
to determine the smallest sample for which at least 80% of simulations
resulted in successful statistical outcomes.

Table 4: Assumptions for power analysis in Study 3

  **Assumptions for Simulating Meant Plantarflexor Impulse (N.m.s/BW)**                         
  ----------------------------------------------------------------------- ------ -------------- ---------------------
                                                                                                
                                                                                 **Baseline**   **Post Adaptation**
  FastBrake                                                               mean   0.40           0.36
                                                                          sd     0.04           0.04
  FastProp                                                                mean   0.40           0.50
                                                                          sd     0.04           0.04

Based on the above and using the assumptions in Table 4. **16 subjects
should be sufficient for 80% power**. For an additional margin of
safety, 20 participants will be included.

Discussion
----------

The objective of this study is to identify the short-term effects of
bilaterally applied Phase-Dependent Speed Variation (PDSV) in a young
and healthy population. This technique attempts to decompose the
perturbation of a conventional Split Belt Treadmill (cSBT) into two
components: stepping onto a faster belt and stepping off a faster belt.
As adaptation to a cSBT evokes spontaneous asymmetrical changes in
plantarflexor (PF) torque (Lauziare et al. 2014), we expect that
adaptation to symmetrically applied PDSV may similarly evoke bilateral
decreases or increases in PF torque. The preliminary results of this
study align with this expectation.

Bibliography
============

Bergen, Gwen, Mark R. Stevens, and Elizabeth R. Burns. 2016. "Falls and
Fall Injuries Among Adults Aged ≥65 Years --- United States, 2014."
*MMWR. Morbidity and Mortality Weekly Report* 65 (37): 993--98.
https://doi.org/10.15585/mmwr.mm6537a2.Delabastita, Tijs, Enzo
Hollville, Andreas Catteau, Philip Cortvriendt, Friedl De Groote, and
Benedicte Vanwanseele. 2021. "Distal-to-Proximal Joint Mechanics
Redistribution Is a Main Contributor to Reduced Walking Economy in Older
Adults." *Scandinavian Journal of Medicine & Science in Sports* 31 (5):
1036--47. https://doi.org/10.1111/sms.13929.DeVita, Paul, and Tibor
Hortobagyi. 2000. "Age Causes a Redistribution of Joint Torques and
Powers during Gait." *Journal of Applied Physiology* 88 (5): 1804--11.
https://doi.org/10.1152/jappl.2000.88.5.1804.Hardy, Susan E., Subashan
Perera, Yazan F. Roumani, Julie M. Chandler, and Stephanie A. Studenski.
2007. "Improvement in Usual Gait Speed Predicts Better Survival in Older
Adults." *Journal of the American Geriatrics Society* 55 (11): 1727--34.
https://doi.org/10.1111/j.1532-5415.2007.01413.x.Kerrigan, D. C., M. K.
Todd, U. Della Croce, L. A. Lipsitz, and J. J. Collins. 1998.
"Biomechanical Gait Alterations Independent of Speed in the Healthy
Elderly: Evidence for Specific Limiting Impairments." *Archives of
Physical Medicine and Rehabilitation* 79 (3): 317--22.
https://doi.org/10.1016/s0003-9993(98)90013-2.Landau, Sabine, and Daniel
Stahl. 2013. "Sample Size and Power Calculations for Medical Studies by
Simulation When Closed Form Expressions Are Not Available." *Statistical
Methods in Medical Research* 22 (3): 324--45.
https://doi.org/10.1177/0962280212439578.Lauziare, S, C MiÃ©ville, M
Betschart, C Duclos, R Aissaoui, and S Nadeau. 2014. "Plantarflexion
Moment Is a Contributor to Step Length After-Effect Following Walking on
a Split-Belt Treadmill in Individuals with Stroke and Healthy
Individuals." *Journal of Rehabilitation Medicine* 46 (9): 849--57.
https://doi.org/10.2340/16501977-1845.Morton, Susanne M., and Amy J.
Bastian. 2006. "Cerebellar Contributions to Locomotor Adaptations during
Splitbelt Treadmill Walking." *The Journal of Neuroscience* 26 (36):
9107--16. https://doi.org/10.1523/JNEUROSCI.2622-06.2006.Nagasaki, H.,
H. Itoh, K. Hashizume, T. Furuna, H. Maruyama, and T. Kinugasa. 1996.
"Walking Patterns and Finger Rhythm of Older Adults." *Perceptual and
Motor Skills* 82 (2): 435--47.
https://doi.org/10.2466/pms.1996.82.2.435.Reisman, Darcy S., Hannah J.
Block, and Amy J. Bastian. 2005. "Interlimb Coordination During
Locomotion: What Can Be Adapted and Stored?" *Journal of
Neurophysiology* 94 (4): 2403--15.
https://doi.org/10.1152/jn.00089.2005.Reisman, Darcy S., Robert Wityk,
Kenneth Silver, and Amy J. Bastian. 2007. "Locomotor Adaptation on a
Split-Belt Treadmill Can Improve Walking Symmetry Post-Stroke." *Brain:
A Journal of Neurology* 130 (Pt 7): 1861--72.
https://doi.org/10.1093/brain/awm035.Schrack, Jennifer A., Eleanor M.
Simonsick, Paulo H.M. Chaves, and Luigi Ferrucci. 2012. "The Role of
Energetic Cost in the Age-Related Slowing of Gait Speed." *Journal of
the American Geriatrics Society* 60 (10): 1811--16.
https://doi.org/10.1111/j.1532-5415.2012.04153.x.Silder, Amy, Bryan
Heiderscheit, and Darryl G. Thelen. 2008. "Active and Passive
Contributions to Joint Kinetics during Walking in Older Adults."
*Journal of Biomechanics* 41 (7): 1520--27.
https://doi.org/10.1016/j.jbiomech.2008.02.016.Umberger, Brian R., and
Philip E. Martin. 2007. "Mechanical Power and Efficiency of Level
Walking with Different Stride Rates." *Journal of Experimental Biology*
210 (18): 3255--65. https://doi.org/10.1242/jeb.000950.
