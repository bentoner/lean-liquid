import for_mathlib.Profinite.extend
import for_mathlib.Profinite.product

import data.fintype.card
import category_theory.limits.functor_category
import category_theory.limits.shapes.binary_products
import category_theory.functor.currying

import facts
import hacks_and_tricks.type_pow

import Lbar.basic
import pseudo_normed_group.profinitely_filtered

/-!
# $\overline{\mathcal{M}}_{r'}(S)_{≤ c}$

In this file we put a profinite topology on the subspace
`Lbar_le r' S c` of `Lbar r' S` consisting of power series
`F_s = ∑ a_{n,s}T^n ∈ Tℤ⟦T⟧` such that `∑_{n,s} |a_{n,s}|r'^n ≤ c`.
-/

universe u

noncomputable theory
open_locale big_operators nnreal
open pseudo_normed_group category_theory category_theory.limits
local attribute [instance] type_pow

variables {r' : ℝ≥0} {S : Type u} [fintype S] {c c₁ c₂ c₃ : ℝ≥0}

/-- `Lbar_le r' S c` is the set of power series
`F_s = ∑ a_{n,s}T^n ∈ Tℤ[[T]]` such that `∑_{n,s} |a_{n,s}|r'^n ≤ c` -/
def Lbar_le (r' : ℝ≥0) (S : Type u) [fintype S] (c : ℝ≥0) :=
{ F : Lbar r' S // F ∈ filtration (Lbar r' S) c }

namespace Lbar_le

instance has_coe : has_coe (Lbar_le r' S c) (Lbar r' S) := ⟨subtype.val⟩

instance has_coe_to_fun : has_coe_to_fun (Lbar_le r' S c) (λ F, S → ℕ → ℤ) := ⟨λ F, F.1⟩

@[simp] lemma coe_coe_to_fun (F : Lbar_le r' S c) : ⇑(F : Lbar r' S) = F := rfl

@[simp] lemma coe_mk (x h) : ((⟨x, h⟩ : Lbar_le r' S c) : S → ℕ → ℤ) = x := rfl

@[simp] protected lemma coeff_zero (x : Lbar_le r' S c) (s : S) : x s 0 = 0 := x.1.coeff_zero' s

protected lemma summable (x : Lbar_le r' S c) (s : S) :
  summable (λ n, (↑(x s n).nat_abs * r'^n)) := x.1.summable' s

protected lemma mem_filtration (x : Lbar_le r' S c) :
  x.1 ∈ filtration (Lbar r' S) c := x.property

/-- The inclusion map `Lbar_le r' S c₁ → Lbar_le r' S c₂` for `c₁ ≤ c₂`. -/
protected def cast_le [hc : fact (c₁ ≤ c₂)] (x : Lbar_le r' S c₁) : Lbar_le r' S c₂ :=
⟨⟨x, x.coeff_zero, x.summable⟩, filtration_mono hc.out x.mem_filtration⟩

@[simp] lemma coe_cast_le [hc : fact (c₁ ≤ c₂)] (x : Lbar_le r' S c₁) :
  ((x.cast_le : Lbar_le r' S c₂) : Lbar r' S) = x :=
by { ext, refl }

@[simp] lemma cast_le_apply [hc : fact (c₁ ≤ c₂)] (x : Lbar_le r' S c₁) (s : S) (i : ℕ) :
  (x.cast_le : Lbar_le r' S c₂) s i = x s i :=
rfl

lemma injective_cast_le [fact (c₁ ≤ c₂)] :
  function.injective (Lbar_le.cast_le : Lbar_le r' S c₁ → Lbar_le r' S c₂) :=
λ x y h,
begin
  ext s n,
  change x.cast_le s n = y.cast_le s n,
  rw h,
end

@[ext] lemma ext (x y : Lbar_le r' S c) (h : (⇑x: S → ℕ → ℤ) = y) : x = y :=
by { ext:2, exact h }

instance : has_zero (Lbar_le r' S c) := ⟨⟨0, zero_mem_filtration _⟩⟩

instance : inhabited (Lbar_le r' S c) := ⟨0⟩

end Lbar_le

variables (c₃)

/-- The addition on `Lbar_le`.
This addition is not homogeneous, but has type
`(Lbar_le r' S c₁) → (Lbar_le r' S c₂) → (Lbar_le r' S c₃)`
for `c₁ + c₂ ≤ c₃`. -/
def Lbar_le.add [h : fact (c₁ + c₂ ≤ c₃)]
  (F : Lbar_le r' S c₁) (G : Lbar_le r' S c₂) :
  Lbar_le r' S c₃ :=
subtype.mk (F + G) $ filtration_mono h.out $ add_mem_filtration F.mem_filtration G.mem_filtration

/-- An uncurried version of addition on `Lbar_le`,
meaning that it takes only 1 input, coming from a product type. -/
def Lbar_le.add' [fact (c₁ + c₂ ≤ c₃)] :
  Lbar_le r' S c₁ × Lbar_le r' S c₂ → Lbar_le r' S c₃ :=
λ x, Lbar_le.add c₃ x.1 x.2

-- TODO: register this as an instance??
/-- The negation on `Lbar_le`. -/
def Lbar_le.neg (F : Lbar_le r' S c) : Lbar_le r' S c :=
subtype.mk (-F) $ neg_mem_filtration F.mem_filtration

namespace Lbar_le

/-- The truncation map from Lbar_le to `Lbar_bdd`. -/
@[simps] def truncate (M : ℕ) (F : Lbar_le r' S c) : Lbar_bdd r' ⟨S⟩ c M :=
{ to_fun := λ s n, F s n,
  coeff_zero' := by simp,
  sum_le' :=
  begin
    refine le_trans _ F.mem_filtration,
    apply finset.sum_le_sum,
    rintros (s : S) -,
    rw fin.sum_univ_eq_sum_range (λ i, (↑(F s i).nat_abs * r' ^i)) (M+1),
    exact sum_le_tsum _ (λ _ _, subtype.property (_ : ℝ≥0)) (F.summable s),
  end }

lemma truncate_surjective (M : ℕ) :
  function.surjective (truncate M : Lbar_le r' S c → Lbar_bdd r' ⟨S⟩ c M) :=
begin
  intro x,
  have aux : _ := _,
  let F : Lbar_le r' S c :=
  ⟨{ to_fun := λ s n, if h : n < M + 1 then x s ⟨n, h⟩ else 0,
     summable' := aux, .. }, _⟩,
  { use F, ext s i, simp only [truncate_to_fun], dsimp,
    rw dif_pos i.is_lt, simp only [fin.eta] },
  { intro s, rw dif_pos (nat.zero_lt_succ _), exact x.coeff_zero s },
  { apply le_trans _ x.sum_le,
    apply finset.sum_le_sum,
    rintro s -,
    rw [← sum_add_tsum_nat_add' (M + 1), tsum_eq_zero, add_zero],
    { rw ← fin.sum_univ_eq_sum_range,
      apply finset.sum_le_sum,
      rintro i -,
      simp only [dif_pos i.is_lt, fin.eta, Lbar.coe_mk] },
    { intro i,
      dsimp,
      rw [dif_neg, int.nat_abs_zero, nat.cast_zero, zero_mul],
      linarith },
    { dsimp, apply aux } },
  { intro s,
    apply @summable_of_ne_finset_zero _ _ _ _ _ (finset.range (M+1)),
    intros i hi,
    rw finset.mem_range at hi,
    simp only [hi, zero_mul, dif_neg, not_false_iff, nat.cast_zero, int.nat_abs_zero] }
end

/-- Injectivity of the map `Lbar_le` to the limit of the `Lbar_bdd`. -/
lemma eq_iff_truncate_eq (x y : Lbar_le r' S c)
  (cond : ∀ M, truncate M x = truncate M y) : x = y :=
begin
  ext s n,
  change (truncate n x).1 s ⟨n, by linarith⟩ = (truncate n y).1 s ⟨n,_⟩,
  rw cond,
end

lemma truncate_cast_le (M : ℕ) [hc : fact (c₁ ≤ c₂)] (x : Lbar_le r' S c₁) :
  truncate M (Lbar_le.cast_le x : Lbar_le r' S c₂) = Lbar_bdd.cast_le (truncate M x) :=
rfl

/-- Underlying function of the element of `Lbar_le r' S c` associated to a sequence of
  elements of the truncated Lbars. -/
def mk_seq (T : Π (M : ℕ), Lbar_bdd r' ⟨S⟩ c M) : S → ℕ → ℤ :=
λ s n, (T n).1 s ⟨n, lt_add_one n⟩

@[simp] lemma mk_seq_zero {T : Π (M : ℕ), Lbar_bdd r' ⟨S⟩ c M} (s : S) : mk_seq T s 0 = 0 :=
(T 0).coeff_zero s

lemma mk_seq_eq_of_compat {T : Π (M : ℕ), Lbar_bdd r' ⟨S⟩ c M}
  (compat : ∀ (M N : ℕ) (h : M ≤ N), Lbar_bdd.transition r' h (T N) = T M)
  {s : S} {n : ℕ} {M : ℕ} (hnM : n < M + 1) :
  mk_seq T s n = (T M).1 s ⟨n, hnM⟩ :=
begin
  have hnM : n ≤ M := nat.lt_succ_iff.mp hnM,
  unfold mk_seq,
  rw ← compat n M hnM,
  apply Lbar_bdd.transition_eq,
end

lemma mk_seq_sum_range_eq (T : Π (M : ℕ), Lbar_bdd r' ⟨S⟩ c M)
  (compat : ∀ (M N : ℕ) (h : M ≤ N), Lbar_bdd.transition r' h (T N) = T M) (s : S) (n) :
  ∑ i in finset.range (n+1), (↑(mk_seq T s i).nat_abs * r'^i) =
  ∑ i : fin (n+1), (↑((T n).1 s i).nat_abs * r'^(i:ℕ)) :=
begin
  rw ← fin.sum_univ_eq_sum_range,
  congr',
  ext ⟨i, hi⟩,
  congr',
  exact mk_seq_eq_of_compat compat _,
end

lemma mk_seq_summable {T : Π (M : ℕ), Lbar_bdd r' ⟨S⟩ c M}
  (compat : ∀ (M N : ℕ) (h : M ≤ N), Lbar_bdd.transition r' h (T N) = T M) (s : S) :
  summable (λ (n : ℕ), (↑(mk_seq T s n).nat_abs * r' ^ n)) :=
begin
  apply @nnreal.summable_of_sum_range_le _ c,
  rintro (_|n),
  { simp only [finset.sum_empty, finset.range_zero, zero_le'] },
  { rw mk_seq_sum_range_eq T compat s n,
    refine le_trans _ (T n).sum_le,
    refine finset.single_le_sum (λ _ _, _) (finset.mem_univ s),
    apply zero_le' },
end

open filter

lemma mk_seq_tendsto {T : Π (M : ℕ), Lbar_bdd r' ⟨S⟩ c M}
  (compat : ∀ (M N : ℕ) (h : M ≤ N), Lbar_bdd.transition r' h (T N) = T M) :
  tendsto (λ (n : ℕ), ∑ (s : S), ∑  i in finset.range n, (↑(mk_seq T s i).nat_abs * r'^i))
  at_top (nhds $ ∑ (s : S), ∑' n, (↑(mk_seq T s n).nat_abs * r'^n)) :=
tendsto_finset_sum _ $ λ s _, has_sum.tendsto_sum_nat $ summable.has_sum $ mk_seq_summable compat s

lemma mk_seq_sum_le {T : Π (M : ℕ), Lbar_bdd r' ⟨S⟩ c M}
  (compat : ∀ (M N : ℕ) (h : M ≤ N), Lbar_bdd.transition r' h (T N) = T M) :
  (∑ s, ∑' (n : ℕ), (↑(mk_seq T s n).nat_abs * r' ^ n)) ≤ c :=
begin
  refine le_of_tendsto (mk_seq_tendsto compat) (eventually_of_forall _),
  rintro (_|n),
  { simp only [finset.sum_empty, finset.range_zero, finset.sum_const_zero, zero_le'] },
  { convert (T n).sum_le,
    funext,
    rw mk_seq_sum_range_eq T compat s n,
    refl }
end

lemma truncate_mk_seq {T : Π (M : ℕ), Lbar_bdd r' ⟨S⟩ c M}
  (compat : ∀ (M N : ℕ) (h : M ≤ N), Lbar_bdd.transition r' h (T N) = T M) (M : ℕ) :
  truncate M ⟨⟨mk_seq T, mk_seq_zero, mk_seq_summable compat⟩, mk_seq_sum_le compat⟩ = T M :=
begin
  ext s ⟨i, hi⟩,
  exact mk_seq_eq_of_compat compat _,
end

/-- `of_compat hT` is the limit of a compatible family `T M : Lbar_bdd r' ⟨S⟩ c M`.
This realizes `Lbar_le` as the profinite limit of the spaces `Lbar_bdd`,
see also `Lbar_le.eqv`. -/
def of_compat {T : Π (M : ℕ), Lbar_bdd r' ⟨S⟩ c M}
  (compat : ∀ (M N : ℕ) (h : M ≤ N), Lbar_bdd.transition r' h (T N) = T M) : Lbar_le r' S c :=
⟨⟨mk_seq T, mk_seq_zero, mk_seq_summable compat⟩, mk_seq_sum_le compat⟩

@[simp] lemma truncate_of_compat {T : Π (M : ℕ), Lbar_bdd r' ⟨S⟩ c M}
  (compat : ∀ (M N : ℕ) (h : M ≤ N), Lbar_bdd.transition r' h (T N) = T M) (M : ℕ) :
  truncate M (of_compat compat) = T M :=
begin
  ext s ⟨i, hi⟩,
  exact mk_seq_eq_of_compat compat _,
end

/-- The equivalence (as types) between `Lbar_le r' S c`
and the profinite limit of the spaces `Lbar_bdd r' ⟨S⟩ c M`. -/
def eqv : Lbar_le r' S c ≃ Lbar_bdd.limit r' ⟨S⟩ c :=
{ to_fun := λ F, ⟨λ N, truncate _ F, by { intros, refl }⟩,
  inv_fun := λ F, of_compat F.2,
  left_inv := λ x, by { ext, refl },
  right_inv := by { rintro ⟨x, hx⟩, simp only [truncate_of_compat], } }

section topological_structure

instance : topological_space (Lbar_le r' S c) := topological_space.induced eqv (by apply_instance)

lemma is_open_iff {U : set (Lbar_bdd.limit r' ⟨S⟩ c)} : is_open (eqv ⁻¹' U) ↔ is_open U :=
begin
  rw is_open_induced_iff,
  have := function.surjective.preimage_injective (equiv.surjective (eqv : Lbar_le r' S c ≃ _)),
  simp only [iff_self, this.eq_iff],
  simp only [exists_eq_right],
end

/-- The homeomorphism between `Lbar_le r' S c`
and the profinite limit of the spaces `Lbar_bdd r' ⟨S⟩ c M`.

This is `Lbar_le.eqv`, lifted to a homeomorphism by transporting
the topology from the profinite limit to `Lbar_le`. -/
def homeo : Lbar_le r' S c ≃ₜ Lbar_bdd.limit r' ⟨S⟩ c :=
{ continuous_to_fun := begin
    simp only [equiv.to_fun_as_coe, continuous_def],
    intros U hU,
    rwa is_open_iff
  end,
  continuous_inv_fun := begin
    simp only [equiv.to_fun_as_coe, continuous_def],
    intros U hU,
    erw [← eqv.image_eq_preimage, ← is_open_iff],
    rwa eqv.preimage_image U,
  end,
  ..eqv }

lemma truncate_eq (M : ℕ) :
  (truncate M : Lbar_le r' S c → Lbar_bdd r' ⟨S⟩ c M) = (Lbar_bdd.proj M) ∘ homeo := rfl

instance : t2_space (Lbar_le r' S c) :=
⟨λ x y h, separated_by_continuous homeo.continuous (λ c, h $ homeo.injective c)⟩

instance [fact (0 < r')] : compact_space (Lbar_le r' S c) :=
begin
  constructor,
  rw homeo.embedding.is_compact_iff_is_compact_image,
  simp only [set.image_univ, homeomorph.range_coe],
  obtain ⟨h⟩ := (by apply_instance : compact_space (Lbar_bdd.limit r' ⟨S⟩ c)),
  exact h,
end

instance : totally_disconnected_space (Lbar_le r' S c) :=
{ is_totally_disconnected_univ :=
  begin
    rintros A - hA,
    suffices subsing : (homeo '' A).subsingleton,
    { intros x hx y hy, apply_rules [homeo.injective, subsing, set.mem_image_of_mem] },
    obtain ⟨h⟩ := (by apply_instance : totally_disconnected_space (Lbar_bdd.limit r' ⟨S⟩ c)),
    exact h _ (by tauto) (is_preconnected.image hA _ homeo.continuous.continuous_on)
  end }

lemma continuous_iff {α : Type*} [topological_space α] (f : α → Lbar_le r' S c) :
  continuous f ↔ (∀ M, continuous ((truncate M) ∘ f)) :=
begin
  split,
  { intros hf M,
    rw [truncate_eq, function.comp.assoc],
    revert M,
    rw ← Lbar_bdd.continuous_iff,
    refine continuous.comp homeo.continuous hf },
  { intro h,
    suffices : continuous (homeo ∘ f), by rwa homeo.comp_continuous_iff at this,
    rw Lbar_bdd.continuous_iff,
    exact h }
end

lemma continuous_truncate {M} : continuous (@truncate r' S _ c M) :=
(continuous_iff id).mp continuous_id _

lemma continuous_add' :
  continuous (Lbar_le.add' (c₁ + c₂) : Lbar_le r' S c₁ × Lbar_le r' S c₂ → Lbar_le r' S (c₁+c₂)) :=
begin
  rw continuous_iff,
  intros M,
  have : truncate M ∘ (λ x : Lbar_le r' S c₁ × Lbar_le r' S c₂, Lbar_le.add _ x.1 x.2) =
    (λ x : (Lbar_le r' S c₁ × Lbar_le r' S c₂), Lbar_bdd.add (truncate M x.1) (truncate M x.2)) :=
    by {ext; refl},
  erw this,
  suffices : continuous (λ x : Lbar_bdd r' ⟨S⟩ c₁ M × Lbar_bdd r' ⟨S⟩ c₂ M, Lbar_bdd.add x.1 x.2),
  { have claim : (λ x : (Lbar_le r' S c₁ × Lbar_le r' S c₂),
      Lbar_bdd.add (truncate M x.1) (truncate M x.2)) =
      (λ x : Lbar_bdd r' ⟨S⟩ c₁ M × Lbar_bdd r' ⟨S⟩ c₂ M, Lbar_bdd.add x.1 x.2) ∘
      (λ x : Lbar_le r' S c₁ × Lbar_le r' S c₂, (truncate M x.1, truncate M x.2)), by {ext, refl},
    rw claim,
    refine continuous.comp this _,
    refine continuous.prod_map continuous_truncate continuous_truncate },
  exact continuous_of_discrete_topology,
end

lemma continuous_neg : continuous (Lbar_le.neg : Lbar_le r' S c → Lbar_le r' S c) :=
begin
  rw continuous_iff,
  intro M,
  change continuous (λ x : Lbar_le r' S c, Lbar_bdd.neg (truncate M x)),
  exact continuous.comp continuous_of_discrete_topology continuous_truncate,
end

end topological_structure

lemma continuous_cast_le (r' : ℝ≥0) (S : Type u) [fintype S] (c₁ c₂ : ℝ≥0) [hc : fact (c₁ ≤ c₂)] :
  continuous (@Lbar_le.cast_le r' S _ c₁ c₂ _) :=
begin
  rw continuous_iff,
  intro M,
  simp only [function.comp, truncate_cast_le],
  exact continuous_bot.comp continuous_truncate
end

/-! We now prove some scaffolding lemmas
in order to prove that the action of `T⁻¹` is continuous. -/

lemma continuous_of_normed_group_hom
  (f : (Lbar r' S) →+ (Lbar r' S))
  (g : Lbar_le r' S c₁ → Lbar_le r' S c₂)
  (h : ∀ x, ↑(g x) = f x)
  (H : ∀ M, ∃ N, ∀ (F : Lbar r' S),
    (∀ s i, i < N + 1 → F s i = 0) → (∀ s i, i < M + 1 → f F s i = 0)) :
  continuous g :=
begin
  rw continuous_iff,
  intros M,
  rcases H M with ⟨N, hN⟩,
  let φ : Lbar_bdd r' ⟨S⟩ c₁ N → Lbar_le r' S c₁ :=
    classical.some (truncate_surjective N).has_right_inverse,
  have hφ : function.right_inverse φ (truncate N) :=
    classical.some_spec (truncate_surjective N).has_right_inverse,
  suffices : truncate M ∘ g = truncate M ∘ g ∘ φ ∘ truncate N,
  { rw [this, ← function.comp.assoc, ← function.comp.assoc],
    apply continuous_bot.comp continuous_truncate },
  ext1 x,
  suffices : ∀ s i, i < M + 1 → (g x) s i = (g (φ (truncate N x))) s i,
  { ext s i, dsimp [function.comp], apply this, exact i.property },
  intros s i hi,
  rw [← coe_coe_to_fun, h, ← coe_coe_to_fun, h, ← sub_eq_zero],
  show ((f x) - f (φ (truncate N x))) s i = 0,
  rw [← f.map_sub],
  apply hN _ _ _ _ hi,
  clear hi i s, intros s i hi,
  simp only [Lbar.coe_sub, pi.sub_apply, sub_eq_zero],
  suffices : ∀ s i, (truncate N x) s i = truncate N (φ (truncate N x)) s i,
  { exact this s ⟨i, hi⟩ },
  intros s i, congr' 1,
  rw hφ (truncate N x)
end

/-- Construct a map between `Lbar_le r' S c₁` and `Lbar_le r' S c₂`
from a bounded group homomorphism `Lbar r' S → Lbar r' S`.

If `f` satisfies a suitable criterion,
then the constructed map is continuous for the profinite topology;
see `continuous_of_normed_group_hom`. -/
def hom_of_normed_group_hom {C : ℝ≥0} (c₁ c₂ : ℝ≥0) [hc : fact (C * c₁ ≤ c₂)]
  (f : Lbar r' S →+ Lbar r' S) (h : f ∈ filtration (Lbar r' S →+ Lbar r' S) C)
  (F : Lbar_le r' S c₁) :
  Lbar_le r' S c₂ :=
⟨{ to_fun := λ s i, f F s i,
  coeff_zero' := Lbar.coeff_zero _,
  summable' := Lbar.summable _ },
  filtration_mono hc.out (h F.mem_filtration)⟩

lemma continuous_hom_of_normed_group_hom {C : ℝ≥0} (c₁ c₂ : ℝ≥0)
  [hc : fact (C * c₁ ≤ c₂)]
  (f : Lbar r' S →+ Lbar r' S) (h : f ∈ filtration (Lbar r' S →+ Lbar r' S) C)
  (H : ∀ M, ∃ N, ∀ (F : Lbar r' S),
    (∀ s i, i < N + 1 → F s i = 0) → (∀ s i, i < M + 1 → f F s i = 0)) :
  continuous (hom_of_normed_group_hom c₁ c₂ f h) :=
continuous_of_normed_group_hom f _ (λ F, by { ext, refl }) H

@[simp] lemma coe_hom_of_normed_group_hom_apply {C : ℝ≥0} (c₁ c₂ : ℝ≥0)
  [hc : fact (C * c₁ ≤ c₂)]
  (f : Lbar r' S →+ Lbar r' S) (h : f ∈ filtration (Lbar r' S →+ Lbar r' S) C)
  (F : (Lbar_le r' S c₁)) (s : S) (i : ℕ) :
  (hom_of_normed_group_hom c₁ c₂ f h) F s i = f F s i := rfl

section Tinv

/-!
### The action of T⁻¹
-/

/-- The action of `T⁻¹` as map `Lbar_le r S c₁ → Lbar_le r S c₂`.

This action is induced by the action of `T⁻¹` on power series modulo constants: `ℤ⟦T⟧/ℤ`.
So `T⁻¹` sends `T^(n+1)` to `T^n`, but `T^0 = 0`. -/
def Tinv {r : ℝ≥0} {S : Type u} [fintype S] {c₁ c₂ : ℝ≥0} [fact (0 < r)] [fact (r⁻¹ * c₁ ≤ c₂)] :
  Lbar_le r S c₁ → Lbar_le r S c₂ :=
hom_of_normed_group_hom c₁ c₂ Lbar.Tinv Lbar.Tinv_mem_filtration

@[simp] lemma Tinv_apply {r : ℝ≥0} {S : Type u} [fintype S] {c₁ c₂ : ℝ≥0}
  [fact (0 < r)] [fact (r⁻¹ * c₁ ≤ c₂)] (F : Lbar_le r S c₁) (s : S) (i : ℕ) :
  (Tinv F : Lbar_le r S c₂) s i = Lbar.Tinv (F : Lbar r S) s i :=
rfl

lemma continuous_Tinv (r : ℝ≥0) (S : Type u) [fintype S] (c₁ c₂ : ℝ≥0)
  [fact (0 < r)] [fact (r⁻¹ * c₁ ≤ c₂)] :
  continuous (@Tinv r S _ c₁ c₂ _ _) :=
continuous_hom_of_normed_group_hom c₁ c₂ _ Lbar.Tinv_mem_filtration $
begin
  intros M,
  use M+1,
  rintro F hF s (_|i) hi,
  { simp only [Lbar.Tinv, add_monoid_hom.mk'_apply, Lbar.coe_mk, Lbar.Tinv_aux_zero] },
  { simp only [Lbar.Tinv, Lbar.Tinv_aux_succ, add_monoid_hom.mk'_apply, Lbar.coe_mk],
    apply hF,
    exact nat.succ_lt_succ hi },
end

end Tinv

/-

section map

/-- TODO -/
def map {S T : Fintype} (f : S ⟶ T) : Lbar_le r' S c → Lbar_le r' T c := λ F,
⟨(F : Lbar r' S).map f, Lbar.nnnorm_map_le_of_nnnorm_le _ _ F.2⟩

lemma map_truncate {S T : Fintype} (f : S ⟶ T) (F : Lbar_le r' S c) (M : ℕ) :
  ((F.truncate M).map f) = (F.map f).truncate M := rfl

lemma map_continuous {S T : Fintype} (f : S ⟶ T) : continuous
  (map f : Lbar_le r' S c → Lbar_le r' T c) :=
begin
  rw continuous_iff,
  intros M,
  have : truncate M ∘ (map f : Lbar_le r' S c → Lbar_le r' T c) =
    Lbar_bdd.map f ∘ truncate M, { ext, refl },
  rw this,
  refine continuous.comp _ continuous_truncate,
  continuity,
end

end map

variables (r' c)

/-- A version of `Lbar_le` which is functorial in `S`. -/
@[simps]
def Fintype_functor [fact (0 < r')] : Fintype.{u} ⥤ Profinite.{u} :=
{ obj := λ S, Profinite.of $ Lbar_le r' S c,
  map := λ S T f,
  { to_fun := map f,
    continuous_to_fun := map_continuous _ },
  map_id' := λ S, begin
    ext1,
    exact subtype.ext x.1.map_id,
  end,
  map_comp' := λ S T U f g, begin
    ext1,
    exact subtype.ext (x.1.map_comp f g),
  end }

variables (c₁ c₂)
/-- The functor sending `S` to the (categorical) product
  of `Lbar_le r' S c₁` and `Lbar_le r' S c₂`. -/
@[simps]
def Fintype_functor_prod [fact (0 < r')] : Fintype.{u} ⥤ Profinite.{u} :=
{ obj := λ S, (S,S),
  map := λ _ _ f, (f,f) } ⋙
    (Fintype_functor r' c₁).prod (Fintype_functor r' c₂) ⋙
    (uncurry.obj prod.functor)

/-- This is a functorial version of `add'`. -/
@[simps]
def Fintype_add_functor [fact (0 < r')] :
  Fintype_functor_prod.{u} r' c₁ c₂ ⟶ Fintype_functor.{u} r' (c₁ + c₂) :=
{ app := λ S, (Profinite.prod_iso _ _).hom ≫ ⟨add' _, continuous_add'⟩,
  naturality' := begin
    intros S T f,
    ext,
    dsimp only [functor.prod, Profinite.prod_iso, Fintype_functor_prod,
      uncurry, prod.functor, functor.comp_map],
    rw [category_theory.limits.prod.map_map, category.comp_id, category.id_comp],
    dsimp [map, Lbar.map, add', add, is_limit.cone_point_unique_up_to_iso,
      is_limit.unique_up_to_iso],
    rw finset.sum_add_distrib,
    -- annoying
    have useful : ∀ {A B C : Profinite} (f : A ⟶ B) (g : B ⟶ C) (a : A),
      (f ≫ g) a = g (f a) := λ _ _ _ _ _ _, rfl,
    congr,
    { have : binary_fan.fst (limit.cone (pair (Profinite.of (Lbar_le r' ↥T c₁))
        (Profinite.of (Lbar_le r' ↥T c₂)))) = category_theory.limits.prod.fst := rfl,
      rw [this, ← useful, category_theory.limits.prod.map_fst],
      refl },
    { have : binary_fan.snd (limit.cone (pair (Profinite.of (Lbar_le r' ↥T c₁))
        (Profinite.of (Lbar_le r' ↥T c₂)))) = category_theory.limits.prod.snd := rfl,
      rw [this, ← useful, category_theory.limits.prod.map_snd],
      refl },
  end}

/-- Negation on `Lbar_le` as a functor in `S`. -/
def Fintype_neg_functor [fact (0 < r')] : Fintype_functor.{u} r' c ⟶ Fintype_functor.{u} r' c :=
{ app := λ S, ⟨Lbar_le.neg, Lbar_le.continuous_neg⟩,
  naturality' := begin
    intros A B f,
    ext,
    dsimp [map, neg],
    simp,
  end }

variables {c₁ c₂}

open category_theory

/-- A bifunctor version of `Fintype_functor`, where `c` can vary. -/
@[simps]
def Fintype_bifunctor [fact (0 < r')] : ℝ≥0 ⥤ Fintype.{u} ⥤ Profinite.{u} :=
{ obj := λ c, Fintype_functor r' c,
  map := λ c₁ c₂ f,
  { app := λ S,
    { to_fun := @Lbar_le.cast_le r' S _ c₁ c₂ ⟨le_of_hom f⟩,
      continuous_to_fun := by apply continuous_cast_le } },
  map_id' := λ c, by { ext, refl },
  map_comp' := λ a b c f g, by { ext, refl } }

/-- The extension of `Fintype_functor` to `Profinite` obtained by taking limits. -/
@[simps]
def functor [fact (0 < r')] : Profinite.{u} ⥤ Profinite.{u} :=
Profinite.extend (Fintype_functor r' c)

variables (c₁ c₂)

/-- The profinite variant of `Fintype_functor_prod`. -/
@[simps]
def functor_prod [fact (0 < r')] : Profinite.{u} ⥤ Profinite.{u} :=
{ obj := λ S, (S,S), map := λ _ _ f, (f, f) } ⋙
  (functor r' c₁).prod (functor r' c₂) ⋙
  (uncurry.obj prod.functor)

/-- A cone over `(S.fintype_diagram ⋙ Fintype_functor_prod r' c₁ c₂)` used in the definition
  of `add_functor`. -/
def functor_prod_cone [fact (0 < r')] (S : Profinite) :
  cone (S.fintype_diagram ⋙ Fintype_functor_prod.{u} r' c₁ c₂) :=
{ X := (functor_prod r' c₁ c₂).obj S,
  π :=
  { app := λ I, category_theory.limits.prod.map (limit.π _ I) (limit.π _ I),
    naturality' := begin
      intros I J f,
      dsimp [Fintype_functor_prod],
      simp [← limit.w _ f],
    end } }

-- TODO: this proof is SLOW.
/-- The profinite variant of `Fintype_add_functor`. -/
def add_functor [fact (0 < r')] : functor_prod.{u} r' c₁ c₂ ⟶ functor.{u} r' (c₁ + c₂) :=
-- Why doesn't this work without the "by apply ..."?
{ app := λ S, by apply limit.lift _ (functor_prod_cone r' c₁ c₂ S) ≫
      category_theory.limits.lim.map (whisker_left _ (Fintype_add_functor _ _ _)),
  naturality' := begin
    intros S T f,
    erw [limits.limit.lift_map, limits.limit.lift_map],
    dsimp only [whisker_left, limits.cones.postcompose],
    apply limit.hom_ext,
    intros I,
    dsimp only [nat_trans.comp_app, functor, Profinite.extend, Profinite.change_cone],
    simp_rw [category.assoc, limits.limit.lift_π],
    change _ = _ ≫ limit.π _ _ ≫ _,
    simp_rw [← category.assoc, limits.limit.lift_π],
    dsimp only [nat_trans.comp_app, functor_prod_cone, functor_prod,
      functor.comp_map, uncurry, limits.prod.functor],
    simp only [limits.prod.map_map, category.id_comp, category.comp_id, category.assoc],
    let e : Fintype.of (I.comap f.continuous) ⟶ Fintype.of I := discrete_quotient.map (le_refl _),
    erw ← (Fintype_add_functor r' c₁ c₂).naturality e,
    simp_rw ← category.assoc,
    dsimp only [Fintype_functor_prod, functor.comp_map, uncurry, limits.prod.functor,
      functor.prod, functor, Profinite.extend],
    simp only [limits.prod.map_map, category.id_comp, category.comp_id, limits.limit.lift_π],
    refl,
  end }

/-- The profinite functorial variant of negation on `Lbar_le`. -/
def neg_functor [fact (0 < r')] : functor.{u} r' c ⟶ functor.{u} r' c :=
{ app := λ X, limits.lim.map $ whisker_left _ $ Fintype_neg_functor _ _,
  naturality' := begin
    intros A B f,
    apply limit.hom_ext,
    intros S,
    dsimp,
    simp,
  end }

variables {c₁ c₂}

/-- A bifunctor version of `functor`, where `c` can vary. -/
@[simps]
def bifunctor [fact (0 < r')] : ℝ≥0 ⥤ Profinite.{u} ⥤ Profinite.{u} :=
{ obj := λ c, functor r' c,
  map := λ a b f, Profinite.extend_nat_trans $ (Fintype_bifunctor r').map f,
  map_id' := begin
    intros c,
    rw (Fintype_bifunctor r').map_id,
    exact Profinite.extend_nat_trans_id _,
  end,
  map_comp' := begin
    intros a b c α β,
    rw (Fintype_bifunctor r').map_comp,
    exact Profinite.extend_nat_trans_comp _ _,
  end }

/-- `Lbar_le.functor r' c` is indeed an extension of `Lbar_le.Fintype_functor r' c`. -/
@[simps]
def functor_extends [fact (0 < r')] :
  Fintype.to_Profinite ⋙ functor.{u} r' c ≅ Fintype_functor.{u} r' c :=
Profinite.extend_extends _ .

variables {r' c}

-/

end Lbar_le

instance [fact (0 < r')] : profinitely_filtered_pseudo_normed_group (Lbar r' S) :=
{ topology := λ c, show topological_space (Lbar_le r' S c), by apply_instance,
  t2 := λ c, show t2_space (Lbar_le r' S c), by apply_instance,
  td := λ c, show totally_disconnected_space (Lbar_le r' S c), by apply_instance,
  compact := λ c, show compact_space (Lbar_le r' S c), by apply_instance,
  continuous_add' := λ c₁ c₂, Lbar_le.continuous_add',
  continuous_neg' := λ c, Lbar_le.continuous_neg,
  continuous_cast_le := λ c₁ c₂,
  begin
    introI h,
    rw show pseudo_normed_group.cast_le = (Lbar_le.cast_le : Lbar_le r' S c₁ → Lbar_le r' S c₂),
      by {ext, refl},
    exact Lbar_le.continuous_cast_le r' S c₁ c₂,
  end,
  .. Lbar.pseudo_normed_group }

/-

namespace Lbar


variable r'

/-- The diagram whose colimit yields `Lbar.profinite`. -/
def profinite_diagram [fact (0 < r')] : ℝ≥0 ⥤ Profinite.{u} ⥤ Type u :=
let E := (whiskering_right Profinite _ _).obj (forget Profinite) in
  ((whiskering_right _ _ _).obj E).obj (Lbar_le.bifunctor.{u} r')

/-- The functor `Lbar : Profinite ⥤ Type*`. -/
@[nolint check_univs] -- TODO remove this
def profinite [fact (0 < r')] : Profinite ⥤ Type* :=
(as_small.down ⋙ profinite_diagram r').flip ⋙ colim

attribute [nolint check_univs] profinite._proof_1

-- TODO: Move this to the condensed folder, once it's more stable!
/-- The representable presheaf associated to a profinite set. -/
def representable : Profinite.{u} ⥤ (as_small.{u+1} Profinite.{u})ᵒᵖ ⥤ Type (u+1) :=
let Y := @yoneda (as_small.{u+1} Profinite.{u}) _ in
((whiskering_right Profinite.{u} _ _).obj Y).obj as_small.up

/-- The diagram whose colimit yields `Lbar.precondensed`. -/
def precondensed_diagram [fact (0 < r')] :
  ℝ≥0 ⥤ Profinite.{u} ⥤ (as_small.{u+1} Profinite.{u})ᵒᵖ ⥤ Type (u+1) :=
let E := (whiskering_right Profinite _ _).obj representable in
((whiskering_right _ _ _).obj E).obj $ Lbar_le.bifunctor.{u} r'

/-- A functor associating to every `S : Profinite` the presheaf associated to the condensed set
`Lbar(S)`. -/
-- TODO: Prove that it is a condensed set!
def precondensed [fact (0 < r')] : Profinite.{u} ⥤ (as_small.{u+1} Profinite.{u})ᵒᵖ ⥤ Type (u+1) :=
(as_small.down.{_ _ (u+1)} ⋙ precondensed_diagram.{u} r').flip  ⋙ colim

end Lbar

-/

#lint-
