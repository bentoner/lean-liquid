import pseudo_normed_group.profinitely_filtered
import prop_92.extension_profinite
import normed_group.normed_with_aut
import for_mathlib.normed_group_hom_completion

import locally_constant.analysis

/-!
This file builds a concrete version of Proposition 9.2, with almost no category.
The exception is that `NormedGroup` is used because this is expected in
`normed_with_aut` (we could easily get rid of this but this is very mild category theory hell).
There are two independent parts. The first one is all about locally constant maps from
compact spaces to semi-normed groups. The next one forget about locally constant functions
and does abstract normed space stuff.
-/

noncomputable theory

@[simp]
lemma real.supr_zero (ι : Type*) : (⨆ i : ι, (0 : ℝ)) = 0 :=
sorry

lemma real.supr_range {α β : Type*} (f : β → α) (g : α → ℝ) :
  (⨆ a ∈ set.range f, g a) = ⨆ b, g (f b) :=
begin
  sorry
end

lemma nnreal.eq_zero_or_pos (r : nnreal) : r = 0 ∨ 0 < r :=
by admit -- can also use lt_or_eq_of_le (zero_le r)

instance semi_normed_group.inhabited (G : Type*) [semi_normed_group G] : inhabited G := ⟨0⟩

section locally_constant_stuff
open topological_space normed_with_aut set
open_locale nnreal big_operators

local attribute [instance] locally_constant.semi_normed_group

/- Comment below indicate how this will be applied to Prop 9.2 -/
variables
  /- this will be M_{≤ r'c}^a -/
  {X : Type*} [topological_space X] [compact_space X]
  /- this will be M_{≤ c}^a -/
  {Y : Type*} [topological_space Y] [compact_space Y] [t2_space Y] [totally_disconnected_space Y]
  /- This will be inclusion -/
  {e : X → Y} (he : embedding e)
  /- This is used only for premilinary lemma not need the T action on V -/
  {G : Type*} [semi_normed_group G]


@[simp]
lemma locally_constant.norm_of_empty (hX : ¬ nonempty X) (f : locally_constant X G) : ∥f∥ = 0 :=
begin
  rw [locally_constant.norm_def, supr],

  sorry
end

@[simp]
lemma embedding.locally_constant_extend_of_empty (hX : ¬ nonempty X) (f : locally_constant X G) :
 he.locally_constant_extend f = 0 :=
begin

  sorry
end

@[simp]
lemma locally_constant.map_zero {Z : Type*} (g : G → Z) :
  (0 : locally_constant X G).map g = locally_constant.const X (g 0) :=
begin

  sorry
end

@[simp]
lemma locally_constant.norm_const [nonempty X] (g : G) : ∥locally_constant.const X g∥ = ∥g∥ :=
begin

  sorry
end

@[simp]
lemma locally_constant.norm_zero : ∥locally_constant.const X (0 : G)∥ = 0 :=
begin
  by_cases hX : nonempty X,
  {
    sorry },
  {
    sorry },
end


lemma locally_constant.exists_norm_eq [nonempty X] (f : locally_constant X G) : ∃ x, ∥f∥ = ∥f x∥ :=
begin
  simp only [locally_constant.norm_def, supr],
  sorry
end

lemma locally_constant.norm_eq_iff (f : locally_constant X G) {x : X} :
  ∥f∥ = ∥f x∥ ↔ ∀ x', ∥f x'∥ ≤ ∥f x∥ :=
begin
  rw [locally_constant.norm_def],
  sorry
end

lemma locally_constant.norm_eq_iff' (f : locally_constant X G) {x : X} :
  ∥f∥ = ∥f x∥ ↔ ∀ g ∈ range f, ∥g∥ ≤ ∥f x∥ :=
sorry

lemma locally_constant.norm_comap {α : Type*} [topological_space α] [compact_space α]
  (f : locally_constant X G) {g : α → X} (h : continuous g) : ∥f.comap g∥ = ∥f∥ :=
sorry


lemma embedding.range_locally_constant_extend [nonempty X] {Z : Type*} [inhabited Z] (f : locally_constant X Z) :
range (he.locally_constant_extend f) = range f :=
begin

  sorry
end


lemma embedding.norm_extend (f : locally_constant X G) : ∥he.locally_constant_extend f∥ = ∥f∥ :=
begin
  by_cases hX : nonempty X,
  { resetI,
    change (⨆ y : Y, _) = (⨆ x : X, _),
    rw  [← real.supr_range, ← real.supr_range, he.range_locally_constant_extend f] },
  { rw [f.norm_of_empty hX],
    dsimp [embedding.locally_constant_extend, embedding.extend],
    suffices : (⨆ (y : Y), ∥(0 : G)∥) = 0,
    by simpa only [hX, dif_neg, not_false_iff, and_false],
    simp }
end

/- lemma embedding.norm_extend_eq [nonempty X] (f : locally_constant X G) :
  ∃ x, ∥f∥ = ∥f x∥ ∧ ∥he.locally_constant_extend f∥ = ∥he.locally_constant_extend f (e x)∥ :=
begin
  cases f.exists_norm_eq with x hx,
  use [x, hx],
  rwa [(he.locally_constant_extend f).norm_eq_iff', he.range_locally_constant_extend,
       he.locally_constant_extend_extends, ← f.norm_eq_iff']
end
 -/

variables
  (φ : X → Y) -- this will be φ is T⁻¹ : M_{≤ r'c}^a → M_{≤ c}^a
  {r : ℝ≥0} {V : NormedGroup} [normed_with_aut r V] -- this is indeed V!

include r

lemma locally_constant.norm_map_aut (g : locally_constant Y V) : ∥g.map T.hom∥ = r*∥g∥ :=
begin
  by_cases hY : nonempty Y,
  { resetI,
    cases g.exists_norm_eq with y hy,
    erw [hy, ← norm_T, locally_constant.norm_eq_iff],
    intro y',
    erw [norm_T, norm_T],
    cases lt_or_eq_of_le (zero_le r) with hr hr,
    { simp [hr, ← hy, g.norm_apply_le] },
    { simp [hr.symm] } },
  { simp [hY] },
end

noncomputable
def embedding.h (f : locally_constant X V) : ℕ → locally_constant Y V
| 0     := (he.locally_constant_extend f).map T.hom
| (i+1) := (he.locally_constant_extend $ (embedding.h i).comap φ).map T.hom

variables (f : locally_constant X V) {φ}

lemma norm_h (hφ : continuous φ) (i : ℕ) : ∥he.h φ f i∥ = r^(i+1)*∥f∥ :=
begin
  induction i with i ih ; dsimp [embedding.h],
  { rw [locally_constant.norm_map_aut, he.norm_extend, zero_add, pow_one] },
  { rw [locally_constant.norm_map_aut, he.norm_extend, (he.h φ f i).norm_comap hφ, ih, ← mul_assoc],
    refl },
end

variables (φ)

def embedding.g (f : locally_constant X V) (N : ℕ) : locally_constant Y V :=
∑ i in finset.range N, he.h φ f i

/-- T⁻¹ g_N e - g_N φ = f - h_N φ-/
lemma one (N : ℕ) :
((he.g φ f N).comap e).map T.inv - ((he.g φ f N).comap φ) = f - (he.h φ f N).comap φ :=
begin

  sorry
end

open filter
open_locale topological_space

lemma limit : tendsto (λ N, ((he.g φ f N).comap e).map T.inv - ((he.g φ f N).comap φ)) at_top (𝓝 f) :=
begin
  -- follows easily from one and norm_h
  sorry
end

lemma cauchy_seq_g : cauchy_seq (he.g φ f) :=
sorry -- follows easily from norm_h and geometry series

lemma norm_g_le (N : ℕ) : ∥he.g φ f N∥ ≤ r/(1 - r) * ∥f∥ :=
sorry -- follows easily from norm_h and geometric series

end locally_constant_stuff

section general_completion_stuff
open filter
open_locale topological_space

-- Now we want an abstract machine where we can plug the sequence g from the previous section.

variables {M₁ : Type*} [semi_normed_group M₁] {M₂ : Type*} [semi_normed_group M₂]
          (f : normed_group_hom M₁ M₂)

/-
The next lemma is a version of normed_group/controlled_exactness.lean but `f` is not assumed to be
surjective. We'll need to abstract part of that older proof
-/

lemma bar {C ε : ℝ} (hε : 0 < ε)
  (h : ∀ m₂ : M₂, ∃ g : ℕ → M₁, cauchy_seq g ∧ tendsto (f ∘ g) at_top (𝓝 m₂) ∧ ∀ n, ∥g n∥ ≤ C*∥f∥) :
  ∀ m₂, ∃ m₁, f.completion m₁ = m₂ ∧ ∥m₁∥ ≤ C*(1+ε)*∥m₂∥ :=
begin

  sorry
end

end general_completion_stuff
