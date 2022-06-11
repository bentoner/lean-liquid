import for_mathlib.imker

noncomputable theory

open category_theory category_theory.limits

namespace cochain_complex

variables {𝓐 : Type*} [category 𝓐] [abelian 𝓐]
variables (C : cochain_complex 𝓐 ℤ)

open_locale zero_object

--This should be the canonical truncation functor `τ_{≤n}` for cochain complexes.
--It is the functor (3) in the second set of truncation functors on this page:
--https://stacks.math.columbia.edu/tag/0118

/-- The "canonical truncation" of a cochain complex (Cⁱ) at an integer `n`,
defined as ... ⟶ Cⁿ⁻² ⟶ Cⁿ⁻¹ ⟶ ker(d : Cⁿ ⟶ Cⁿ⁺¹) ⟶ 0 ⟶ 0 ⟶ ..., with the kernel
in degree `n`. -/
def truncation (C : cochain_complex 𝓐 ℤ) (n : ℤ) : cochain_complex 𝓐 ℤ :=
{ X := λ i, if i < n
    then C.X i
    else if i = n
      then kernel (C.d n (n+1))
      else 0,
  d := λ i j, if hi : i + 1 = j -- (complex_shape.up ℤ).rel i j
    then if hj : j < n
      then eq_to_hom (by rw if_pos (lt_trans (show i < j, by linarith) hj)) ≫ C.d i j ≫ eq_to_hom (by rw if_pos hj)
      else if hj_eq : j = n
        then eq_to_hom (by rw if_pos (show i < n, by linarith)) ≫
          eq_to_hom (by rw (show i = n - 1, by linarith)) ≫
          (kernel.lift (C.d n (n+1)) (C.d (n-1) n) (C.d_comp_d (n-1) n (n+1)) : C.X (n-1) ⟶ kernel (C.d n (n+1))) ≫
          eq_to_hom (by rw [if_neg hj, if_pos hj_eq])
        else 0
    else 0,
  shape' := λ i j, begin
    rintro h : ¬ (i + 1) = j,
    rw dif_neg h,
  end,
  d_comp_d' := λ i j k, begin
    rintro (rfl : i + 1 = j) (rfl : i + 1 + 1 = k),
    rw dif_pos rfl,
    by_cases hin : i + 1 < n,
    { rw dif_pos hin,
      rw dif_pos rfl,
      by_cases hin' : i + 1 + 1 < n,
      { rw dif_pos hin',
        simp only [category.assoc, eq_to_hom_trans_assoc, eq_to_hom_refl, category.id_comp,
          homological_complex.d_comp_d_assoc, zero_comp, comp_zero], },
      { rw dif_neg hin',
        have hn : n = i + 1 + 1, linarith,
        subst hn,
        rw dif_pos rfl,
        simp only [eq_to_hom_trans_assoc, category.assoc, preadditive.is_iso.comp_left_eq_zero],
        rw [← category.assoc, ← category.assoc, imker.comp_mono_zero_iff],
        ext,
        simp, } },
    { rw dif_neg hin,
      by_cases hn : i + 1 = n,
      { rw [dif_pos hn, dif_pos rfl, dif_neg (show ¬ i + 1 + 1 < n, by linarith),
          dif_neg (show ¬ i + 1 + 1 = n, by linarith), comp_zero], },
      { rw [dif_neg hn, zero_comp], } },
  end }

namespace truncation

@[reducible] def X_iso_of_lt {i n : ℤ} (h : i < n) : (C.truncation n).X i ≅ C.X i :=
eq_to_iso (by simp [truncation, if_pos h] )

-- don't know whether to go for kernel of d_n or of d_i!
@[reducible] def X_iso_of_eq {i n : ℤ} (h : i = n) : (C.truncation n).X i ≅ kernel (C.d n (n+1)) :=
eq_to_iso (by subst h; simp [truncation, if_neg (show ¬ i < i, by linarith)] )

@[reducible] def X_iso_of_eq' {i n : ℤ} (h : i = n) : (C.truncation n).X i ≅ kernel (C.d i (i+1)) :=
eq_to_iso (by subst h; simp [truncation, if_neg (show ¬ i < i, by linarith)] )

lemma is_zero_X_of_lt {i n : ℤ} (h : n < i) : is_zero ((C.truncation n).X i) :=
begin
  simp [truncation, if_neg (show ¬ i < n, by linarith), if_neg (show ¬ i = n, by linarith),
    is_zero_zero],
end

lemma bounded_by (n : ℤ) :
  ((homotopy_category.quotient _ _).obj (C.truncation n)).bounded_by (n+1) :=
begin
  intros i hi,
  dsimp only [homotopy_category.quotient_obj_as, truncation],
  rw [if_neg, if_neg],
  { apply is_zero_zero, },
  { linarith },
  { linarith }
end

instance is_bounded_above (n : ℤ) :
  ((homotopy_category.quotient _ _).obj (C.truncation n)).is_bounded_above :=
⟨⟨n+1, bounded_by C n⟩⟩

def ι (n : ℤ) : C.truncation n ⟶ C :=
{ f := λ i, if hin : i < n
    then (X_iso_of_lt C hin).hom
    else if hi : i = n
      then (X_iso_of_eq C hi).hom ≫ kernel.ι _ ≫ eq_to_hom (by rw hi)
      else 0,
  comm' := λ i j, begin
    rintro (rfl : i + 1 = j),
    dsimp only [truncation],
    simp only [eq_self_iff_true, eq_to_hom_trans_assoc, dif_pos],
    by_cases hiltn : i < n,
    { rw dif_pos hiltn,
      by_cases hi1ltn : i + 1 < n,
      { rw [dif_pos hi1ltn, dif_pos hi1ltn],
        simp,
        refl, },
      { have hn : i + 1 = n, linarith,
        subst hn,
        rw [dif_neg hi1ltn, dif_neg hi1ltn],
        rw [dif_pos rfl, dif_pos rfl ],
        simp only [eq_to_iso.hom, eq_to_hom_refl, category.comp_id, category.assoc,
          eq_to_hom_trans_assoc, category.id_comp, kernel.lift_ι],
        congr'; linarith, } },
    { rw dif_neg hiltn,
      by_cases hin : i = n,
      { subst hin,
        simp, },
      { rw dif_neg hin,
        rw dif_neg (show ¬ i + 1 < n, by linarith),
        rw dif_neg (show ¬ i + 1 = n, by linarith),
        simp, } },
  end }

def ι_inv (n : ℤ) (hn : is_zero (C.X (n + 1))) : C ⟶ C.truncation n :=
{ f := λ i, if hin : i < n
    then (X_iso_of_lt C hin).inv
    else if hi : i = n
      then (eq_to_hom (by rw hi) : C.X i ⟶ C.X n) ≫
        kernel.lift (C.d n (n+1)) (𝟙 (C.X n)) (hn.eq_zero_of_tgt _) ≫
        (X_iso_of_eq C hi).inv
      else 0,
  comm' := λ i j, begin
    rintro (rfl : i + 1 = j),
    dsimp only [truncation],
    simp only [eq_self_iff_true, eq_to_iso.inv, eq_to_hom_trans_assoc, dif_pos],
    by_cases hiltn : i < n,
    { rw dif_pos hiltn,
      by_cases hi1ltn : i + 1 < n,
      { simp [dif_pos hi1ltn], },
      { have hi1n : i + 1 = n, linarith,
        subst hi1n,
        simp only [eq_self_iff_true, add_left_inj, lt_self_iff_false, not_false_iff, dif_pos,
          dif_neg, eq_to_hom_trans_assoc, eq_to_hom_refl, category.id_comp, ← category.assoc],
        congr' 1,
        ext,
        simp, } },
    { rw dif_neg hiltn,
      by_cases hin : i = n,
      { simp [hin], },
      { rw [dif_neg hin, zero_comp],
        rw dif_neg (show ¬ i + 1 < n, by linarith),
        rw [dif_neg (show ¬ i + 1 = n, by linarith), comp_zero], }, },
  end }

lemma ι_iso (n : ℤ) (hC : ((homotopy_category.quotient _ _).obj C).bounded_by (n+1)) :
  is_iso (truncation.ι C n) :=
{ out := ⟨ι_inv C n (hC (n+1) (by refl)),
  by {
    ext i,
    simp only [homological_complex.comp_f, homological_complex.id_f, ι, ι_inv, eq_to_iso.hom,
      eq_to_iso.inv],
    by_cases hiltn : i < n,
    { simp [dif_pos hiltn], },
    { rw [dif_neg hiltn, dif_neg hiltn],
      by_cases hin : i = n,
      { subst hin,
        simp only [eq_self_iff_true, eq_to_hom_refl, dif_pos, category.id_comp, category.assoc],
        rw ← category.assoc (kernel.ι (C.d i (i + 1))),
        suffices : kernel.ι (C.d i (i + 1)) ≫ kernel.lift (C.d i (i + 1)) (𝟙 (C.X i)) _ = 𝟙 _,
        { simp [this] },
        { ext,
          simp },
        { apply is_zero.eq_zero_of_tgt,
          simpa using hC (i + 1) (by refl), } },
      { apply is_zero.eq_of_tgt,
        apply is_zero_X_of_lt,
        push_neg at hiltn,
        obtain (h1 | h2) := lt_or_eq_of_le hiltn,
        { exact h1 },
        { exact (hin h2.symm).elim, } } } },
  begin
    ext i,
    simp only [ι, ι_inv, eq_to_iso.inv, eq_to_iso.hom, homological_complex.comp_f,
      homological_complex.id_f],
        by_cases hiltn : i < n,
    { simp [dif_pos hiltn], },
    { rw [dif_neg hiltn, dif_neg hiltn],
      by_cases hin : i = n,
      { subst hin,
        simp only [eq_to_hom_refl, category.id_comp, dif_pos, category.comp_id, category.assoc,
          eq_to_hom_trans_assoc, kernel.lift_ι], },
      { apply is_zero.eq_of_tgt,
        simpa using hC i _,
        push_neg at hiltn,
        obtain (h1 | h2) := lt_or_eq_of_le hiltn,
        { exact int.add_one_le_iff.mpr h1, },
        { exact (hin h2.symm).elim, } } }
  end⟩ }

-- feel free to skip this, and directly provide a defn for `ι_succ` below
def map_of_le (m n : ℤ) (h : m ≤ n) : C.truncation m ⟶ C.truncation n :=
{ f := λ i, if him : i < m
    then (X_iso_of_lt C him).hom ≫
      (X_iso_of_lt C (lt_of_lt_of_le him h)).inv -- id
    else if him' : i = m -- domain is ker(d)
      then if hin : i < n
        then (X_iso_of_eq C him').hom ≫ kernel.ι _ ≫
          (eq_to_hom (by rw him') : C.X m ⟶ C.X i) ≫ (X_iso_of_lt C hin).inv -- kernel.ι
        else (X_iso_of_eq' C him').hom ≫ (X_iso_of_eq' C (by linarith : i = n)).inv -- identity
      else 0,
  comm' := λ i j, begin
    rintro (rfl : _ = _),
    delta truncation,
    dsimp only [zero_add, neg_zero, add_zero, zero_lt_one, neg_neg, neg_eq_zero, homological_complex.d_comp_d, dif_neg, dif_pos,
  category.assoc, eq_to_hom_trans_assoc, eq_to_hom_refl, category.id_comp, homological_complex.d_comp_d_assoc,
  zero_comp, comp_zero, preadditive.is_iso.comp_left_eq_zero, imker.comp_mono_zero_iff,
  homological_complex.d_comp_eq_to_hom, add_tsub_cancel_right, complex_shape.up_rel, add_left_inj, eq_self_iff_true,
  equalizer_as_kernel, kernel.lift_ι, mul_one],
    simp only [eq_self_iff_true, eq_to_iso.hom, eq_to_iso.inv, eq_to_hom_trans, eq_to_hom_trans_assoc, dif_pos],
    by_cases him : i < m,
    { rw dif_pos him,
      by_cases hi1n : i + 1 < n,
      { rw dif_pos hi1n,
        by_cases hi1m : i + 1 < m,
        { simp [dif_pos hi1m], },
        { have hm : i + 1 = m, linarith,
          subst hm,
          rw [dif_neg hi1m, dif_pos rfl, dif_neg hi1m, dif_pos rfl, dif_pos hi1n],
          simp only [eq_to_hom_trans_assoc, category.assoc, eq_to_hom_refl, category.id_comp, kernel.lift_ι_assoc],
          congr';
          ring,
        }
      },
      { rw dif_neg hi1n,
        have hn : i + 1 = n, linarith,
        subst hn,
        have hm : m = i + 1, linarith,
        subst hm,
        simp, } },
    { rw dif_neg him,
      by_cases hm : i = m,
      { subst hm,
        rw [dif_pos rfl, dif_neg (show ¬ (i + 1) < i, by linarith),
          dif_neg (show ¬ i + 1 = i, by linarith), zero_comp],
        obtain (hn | rfl) := lt_or_eq_of_le h,
        { rw dif_pos hn,
          by_cases hi1n : i + 1 < n,
          { rw dif_pos hi1n,
            simp, },
          { rw dif_neg hi1n,
            have hn2 : i + 1 = n, linarith,
            subst hn2,
            simp,
            have hi : eq_to_hom _ ≫ kernel.lift (C.d (i + 1) (i + 1 + 1)) (C.d (i + 1 - 1) (i + 1)) _ = kernel.lift (C.d (i + 1) (i + 1 + 1)) (C.d i (i + 1)) _,
            { ext, simp, },
            rw [← category.assoc (eq_to_hom _), hi],
            swap, apply C.d_comp_d,
            rw ← category.assoc,
            convert zero_comp,
            ext, simp, } },
        { rw [dif_neg him, dif_neg (show ¬ i + 1 < i, by linarith),
            dif_neg (show i + 1 ≠ i, by linarith), comp_zero], }
      },
      { rw [dif_neg hm, zero_comp, dif_neg (show ¬ i + 1 < m, by linarith),
          dif_neg (show i + 1 ≠ m, by linarith), zero_comp],
      } }
  end }
.

def ι_succ (n : ℤ) : C.truncation n ⟶ C.truncation (n+1) :=
truncation.map_of_le _ _ _ $ by simp only [le_add_iff_nonneg_right, zero_le_one]

--move
lemma _root_.homological_complex.d_from_eq_d_comp_X_next_iso_inv {ι V : Type*} [category V]
  [has_zero_morphisms V] {c : complex_shape ι} (C : homological_complex V c) [has_zero_object V]
    {i j : ι} (r : c.rel i j) :
  C.d_from i = C.d i j ≫ (C.X_next_iso r).inv :=
by simp [C.d_from_eq r]

--- move
@[simp, reassoc] lemma _root_.category_theory.limits.eq_to_hom_comp_image.ι {C : Type*} [category C] {X Y : C} {f f' : X ⟶ Y}
  [has_image f] [has_image f'] [has_equalizers C] (h : f = f') :
(eq_to_hom (by simp_rw h)) ≫ image.ι f' = image.ι f :=
begin
  unfreezingI {subst h},
  simp,
end

--- move
@[simp, reassoc] lemma _root_.category_theory.limits.eq_to_hom_comp_kernel.ι {C : Type*}
  [category C] [abelian C] {X Y : C} {f f' : X ⟶ Y} (h : f = f') :
(eq_to_hom (by simp_rw h)) ≫ kernel.ι f' = kernel.ι f :=
begin
  unfreezingI {subst h},
  simp,
end

-- move
attribute [reassoc] homological_complex.d_comp_eq_to_hom

-- move
lemma _root_.category_theory.limits.factor_thru_image_of_eq {A B : 𝓐} {f f' : A ⟶ B} (h : f = f') :
factor_thru_image f ≫ (eq_to_hom (by rw h)) = factor_thru_image f' :=
begin
  subst h,
  simp,
end


-- move
@[ext] lemma image.ι.hom_ext {A B X : 𝓐} (f : A ⟶ B) (s t : X ⟶ image f)
  (h : s ≫ image.ι f = t ≫ image.ι f) : s = t :=
by rwa cancel_mono at h

-- move
@[reassoc] lemma comp_factor_thru_image_eq_zero {A B C : 𝓐} {f : A ⟶ B} {g : B ⟶ C}
  (w : f ≫ g = 0) : f ≫ factor_thru_image g = 0 :=
begin
  ext,
  simp [w],
end

@[simp, reassoc] lemma kernel_ι_comp_factor_thru_image {A B : 𝓐} {f : A ⟶ B} :
kernel.ι f ≫ factor_thru_image f = 0 :=
comp_factor_thru_image_eq_zero (kernel.condition f)

def to_imker (n : ℤ) : C.truncation n ⟶ imker C n :=
{ f := λ i, if hi : i = n - 1
           then (X_iso_of_lt C (show i < n, by linarith)).hom ≫ eq_to_hom (by rw hi) ≫
           factor_thru_image (C.d (n-1) n) ≫
           (eq_to_hom (by { rw ← C.X_prev_iso_comp_d_to, show (n - 1) + 1 = n, ring, })) ≫
             image.pre_comp (C.X_prev_iso (show (n - 1) + 1 = n, by ring)).inv (C.d_to n) ≫
             (imker.X_iso_image_of_eq C hi).inv -- C(n-1) ⟶ Im(d^{n-1})
           else if hn : i = n
             then (X_iso_of_eq C hn).hom ≫
             kernel.lift (C.d n (n+1) ≫ (C.X_next_iso (show n + 1 = n + 1, from rfl)).inv) (kernel.ι _) (by {rw [← category.assoc, kernel.condition, zero_comp]}) ≫
             eq_to_hom begin simp_rw ← C.d_from_eq_d_comp_X_next_iso_inv, end ≫
             (imker.kernel_iso_X_of_eq C hn).hom
             else 0,
  comm' := λ i j, begin
    rintro (rfl : _ = _),
    by_cases hi : i = n - 1,
    { rw dif_pos hi,
      subst hi,
      delta imker truncation, dsimp only,
      rw [dif_pos rfl, dif_pos (show n - 1 + 1 = n, by ring), dif_pos rfl,
        dif_neg (show ¬ n - 1 + 1 < n, by linarith), dif_pos (show n - 1 + 1 = n, by ring),
        dif_neg (show n - 1 + 1 ≠ n - 1, by linarith), dif_pos (show n - 1 + 1 = n, by ring)],
      simp only [← category.assoc],
      congr' 1,
      ext,
      delta image_to_kernel',
      simp only [homological_complex.X_prev_iso_comp_d_to, category.assoc, eq_to_iso.hom, eq_to_hom_refl, category.comp_id,
  imker.X_iso_image_of_eq_inv, eq_to_hom_trans, kernel.lift_ι, image.pre_comp_ι,
  category_theory.limits.eq_to_hom_comp_image.ι, image.fac, category_theory.limits.eq_to_hom_comp_kernel.ι],
      refl, },
    { rw dif_neg hi,
      by_cases hn : i = n,
      { subst hn,
        simp only [dif_neg (show i + 1 ≠ i - 1, by linarith), imker.d_def, add_right_eq_self, one_ne_zero, not_false_iff, dif_neg, dite_eq_ite, if_t_t, comp_zero], },
      { rw dif_neg hn,
        by_cases hin : i + 1 = n - 1,
        { rw dif_pos hin,
          have hi : i = n - 2, linarith, subst hi,
          delta truncation, dsimp only,
          simp only [dif_pos (show (n - 2) + 1 < n, by linarith),
            C.d_comp_eq_to_hom_assoc (show (n - 2) + 1 = n - 1, by ring),
            comp_factor_thru_image_eq_zero_assoc, homological_complex.d_comp_d, eq_to_iso.hom, zero_comp, eq_to_hom_trans_assoc,
  dif_pos, category.assoc, complex_shape.up_rel, comp_zero], },
        { rw dif_neg hin,
          rw dif_neg (show i + 1 ≠ n, by {intro h, apply hi, linarith}),
          rw [zero_comp, comp_zero], } } }
  end }
.

-- move!
lemma lt_of_not_lt_of_ne {a b : ℤ} (h1 : ¬ a < b) (h2 : ¬ a = b) : b < a :=
begin
  rcases lt_trichotomy a b with (h3 | rfl | h3),
  { contradiction },
  { exact h2.elim rfl },
  { exact h3 }
end

-- move!
instance kernel.lift_iso_of_iso {A B C : 𝓐} (f : A ⟶ B) (e : B ⟶ C) [is_iso e] :
  is_iso (kernel.lift (f ≫ e) (kernel.ι f) (by simp) : kernel f ⟶ kernel (f ≫ e)) :=
⟨⟨kernel.lift _ (kernel.ι (f ≫ e))  (by { rw ← cancel_mono e, simp }), by {ext, simp}, by {ext, simp}⟩⟩

instance {i n : ℤ} : epi ((to_imker C i).f n) :=
begin
  delta to_imker, dsimp only,
  split_ifs with hn hi,
  { subst hn,
    simp only [imker.epi_comp_is_iso_iff_epi, imker.epi_is_iso_comp_iff_epi,
      factor_thru_image.category_theory.epi], },
  { subst hi,
    simp,
    apply_instance, },
  { apply epi_of_target_iso_zero,
    exact is_zero.iso_zero (imker.X_is_zero_of_ne C hn hi), }
end

lemma map_of_le_mono {m n : ℤ} (h : m ≤ n) (i : ℤ) : mono ((map_of_le C m n h).f i) :=
begin
  delta map_of_le, dsimp only,
  split_ifs with hnotlt hnoteq; try {apply_instance},
  apply mono_of_source_iso_zero,
  exact is_zero.iso_zero (is_zero_X_of_lt C (lt_of_not_lt_of_ne hnotlt hnoteq)),
end

instance ι_succ_mono {i n : ℤ} : mono ((ι_succ C i).f n) :=
begin
  delta ι_succ,
  apply map_of_le_mono,
end

-- has_homology version of exact
lemma _root_.abelian.exact_iff_has_homology_zero {A B C : 𝓐} (f : A ⟶ B) (g : B ⟶ C) :
  exact f g ↔ ∃ w : f ≫ g = 0, nonempty (has_homology f g 0) :=
begin
  rw preadditive.exact_iff_homology_zero,
  apply exists_congr,
  intro w,
  split,
  { rintro ⟨h⟩,
    exact ⟨(homology.has f g w).of_iso h⟩ },
  { rintro ⟨h⟩,
    exact ⟨(homology.has f g w).iso h⟩, },
end

lemma ι_succ.comp_to_imker_zero {i n : ℤ} : (ι_succ C i).f n ≫ (to_imker C (i + 1)).f n = 0 :=
begin
  delta ι_succ map_of_le to_imker,
  dsimp only [le_add_iff_nonneg_right, zero_le_one, neg_zero, zero_add, add_zero, zero_lt_one, neg_neg, neg_eq_zero,
  homological_complex.d_comp_d, dif_neg, dif_pos, category.assoc, eq_to_hom_trans_assoc, eq_to_hom_refl,
  category.id_comp, homological_complex.d_comp_d_assoc, zero_comp, comp_zero, preadditive.is_iso.comp_left_eq_zero,
  imker.comp_mono_zero_iff, homological_complex.d_comp_eq_to_hom, add_tsub_cancel_right, complex_shape.up_rel,
  add_left_inj, eq_self_iff_true, equalizer_as_kernel, kernel.lift_ι, mul_one, eq_to_iso.hom, eq_to_iso.inv,
  eq_to_hom_trans, kernel.lift_ι_assoc, add_lt_add_iff_right, lt_self_iff_false, not_false_iff, dite_eq_ite, if_true,
  if_false, category.comp_id, kernel.condition_assoc, homological_complex.eq_to_hom_comp_d, kernel.condition,
  homological_complex.X_prev_iso_comp_d_to, homological_complex.d_to_comp_d_from, add_right_eq_self, one_ne_zero,
  image.fac_assoc, imker.X_iso_image_of_eq_inv, image.pre_comp_ι, category_theory.limits.eq_to_hom_comp_image.ι,
  image.fac, category_theory.limits.eq_to_hom_comp_kernel.ι, imker.d_def, if_t_t,
  homological_complex.d_comp_eq_to_hom_assoc], -- lol thanks squeeze_dsimp
  by_cases h : n < i,
  { rw [dif_pos h, dif_neg (show n ≠ i + 1 - 1, by linarith), dif_neg (show n ≠ i + 1, by linarith),
      comp_zero], },
  { rw dif_neg h,
    by_cases hn : n = i,
    { rw dif_pos hn,
      subst hn,
      rw [dif_pos (show n < n + 1, by linarith), dif_pos (show n = n + 1 - 1, by ring),
        ← image.factor_thru_image_pre_comp_assoc, ← category_theory.limits.factor_thru_image_of_eq
          ((C.eq_to_hom_comp_d rfl (show n + 1 - 1 + 1 = n + 1, by ring)).symm)],
      simp,
    },
    { rw [dif_neg hn, zero_comp], } },
end

def ι_succ_to_imker_has_homology_zero {i n : ℤ} :
  has_homology ((ι_succ C i).f n) ((to_imker C (i + 1)).f n) 0 :=
{ w := ι_succ.comp_to_imker_zero C,
  π := 0,
  ι := 0,
  π_ι := sorry,
  ex_π := sorry,
  ι_ex := sorry,
  epi_π := epi_of_target_iso_zero _ (iso.refl _),
  mono_ι := mono_of_source_iso_zero _ (iso.refl _) }

lemma short_exact_ι_succ_to_imker (i : ℤ) (n : ℤ) :
  short_exact ((ι_succ C i).f n) ((to_imker C (i+1)).f n) :=
{ mono := infer_instance,
  epi := infer_instance,
  exact := begin
    rw abelian.exact_iff_has_homology_zero,
    exact ⟨ι_succ.comp_to_imker_zero C, ⟨ι_succ_to_imker_has_homology_zero C⟩⟩,
end }

end truncation

end cochain_complex
