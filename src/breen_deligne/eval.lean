import category_theory.preadditive.functor_category
import category_theory.limits.shapes.finite_products
import category_theory.limits.shapes.biproducts

import for_mathlib.homological_complex2

import breen_deligne.homotopy

noncomputable theory

open_locale big_operators

open category_theory category_theory.limits

namespace category_theory
namespace preadditive

variables {𝒜 : Type*} [category 𝒜] [has_zero_morphisms 𝒜] [has_finite_biproducts 𝒜]

-- move this
@[simps {fully_applied := ff}]
def Pow (n : ℕ) : 𝒜 ⥤ 𝒜 :=
{ obj := λ A, ⨁ (λ (i : ulift $ fin n), A),
  map := λ A B f, biproduct.map (λ i, f),
  map_id' := λ A, by { ext i j, simp only [biproduct.ι_map, category.id_comp, category.comp_id], },
  map_comp' := λ A B C f g, by { ext i j, simp only [biproduct.ι_map_assoc, category.assoc], } }

-- move this
attribute [simps] comp_hom

end preadditive
end category_theory

namespace homotopy

variables {ι 𝒜 : Type*} [category 𝒜] [preadditive 𝒜] {c : complex_shape ι}
variables {C D : homological_complex 𝒜 c} {f g : C ⟶ D}

@[simps]
def congr (h : homotopy f g) (f' g' : C ⟶ D) (hf : f = f') (hg : g = g') :
  homotopy f' g' :=
{ comm := by simpa only [hf, hg] using h.comm,
  .. h }

end homotopy

namespace breen_deligne

open category_theory.preadditive

variables (BD : data)
variables {𝒜 : Type*} [category 𝒜] [preadditive 𝒜] [has_finite_biproducts 𝒜]
variables (F : 𝒜 ⥤ 𝒜)

namespace basic_universal_map

variables {m n o : ℕ} (f : basic_universal_map m n) (g : basic_universal_map n o)

@[simps {fully_applied := ff}]
def eval_Pow : (Pow m : 𝒜 ⥤ 𝒜) ⟶ Pow n :=
{ app := λ A, biproduct.matrix (λ i j, f j.down i.down • 𝟙 A),
  naturality' := begin
    intros, ext i j,
    simp only [Pow_map, biproduct.ι_map_assoc, category.assoc, biproduct.matrix_π,
      biproduct.map_π, biproduct.ι_desc, biproduct.matrix_π_assoc, biproduct.ι_desc_assoc,
      comp_zsmul, zsmul_comp, category.comp_id, category.id_comp],
  end }

@[simp] lemma eval_Pow_comp : @eval_Pow 𝒜 _ _ _ _ _ (comp g f) = f.eval_Pow ≫ g.eval_Pow :=
begin
  ext A i j,
  simp only [eval_Pow_app, nat_trans.comp_app, category.assoc, biproduct.ι_map_assoc,
    biproduct.matrix_π, biproduct.ι_matrix_assoc, biproduct.lift_desc,
    biproduct.map_π, biproduct.ι_desc, biproduct.matrix_π_assoc, biproduct.ι_desc_assoc,
    comp_zsmul, zsmul_comp, category.comp_id, category.id_comp],
  simp only [comp, add_monoid_hom.mk'_apply, matrix.mul, matrix.dot_product,
    finset.sum_smul, mul_smul],
  rw [← (@equiv.ulift (fin n)).symm.sum_comp, finset.sum_congr rfl],
  rintros j -,
  rw smul_comm, refl,
end

end basic_universal_map

namespace universal_map

variables {m n o : ℕ} (f : universal_map m n) (g : universal_map n o)

def eval_Pow : universal_map m n →+ (Pow m ⋙ F ⟶ Pow n ⋙ F) :=
free_abelian_group.lift $ λ g : basic_universal_map m n, whisker_right g.eval_Pow F

lemma eval_Pow_of (g : basic_universal_map m n) :
  eval_Pow F (free_abelian_group.of g) = whisker_right g.eval_Pow F :=
free_abelian_group.lift.of _ _

@[simp] lemma eval_Pow_zero : eval_Pow F (0 : universal_map m n) = 0 :=
add_monoid_hom.map_zero _

lemma eval_Pow_zero_app (A : 𝒜) : (eval_Pow F (0 : universal_map m n)).app A = 0 :=
by rw [eval_Pow_zero, zero_app]

lemma eval_Pow_comp : eval_Pow F (universal_map.comp g f) = eval_Pow F f ≫ eval_Pow F g :=
begin
  rw [← add_monoid_hom.comp_apply, ← add_monoid_hom.comp_hom_apply_apply,
    ← add_monoid_hom.comp_apply, eq_comm,
    ← category_theory.preadditive.comp_hom_apply_apply, ← add_monoid_hom.flip_apply,
    ← add_monoid_hom.comp_apply, ← add_monoid_hom.comp_hom_apply_apply,
    ← add_monoid_hom.flip_apply _ _ (eval_Pow F),
    ← add_monoid_hom.comp_apply, ← add_monoid_hom.comp_hom_apply_apply,
    ← add_monoid_hom.comp_apply, ← add_monoid_hom.comp_hom_apply_apply],
  congr' 2,
  clear f g,
  ext g f : 2,
  simp only [add_monoid_hom.comp_hom_apply_apply, add_monoid_hom.comp_apply,
    add_monoid_hom.flip_apply, category_theory.preadditive.comp_hom_apply_apply,
    comp_of, eval_Pow_of, whisker_right_comp, basic_universal_map.eval_Pow_comp],
end

lemma eval_Pow_comp_app (A : 𝒜) :
  (eval_Pow F (universal_map.comp g f)).app A = (eval_Pow F f).app A ≫ (eval_Pow F g).app A :=
by rw [eval_Pow_comp, nat_trans.comp_app]

@[simps {fully_applied := ff}]
def eval_Pow_functor : FreeMat ⥤ (𝒜 ⥤ 𝒜) :=
{ obj := λ n, Pow n ⋙ F,
  map := λ m n f, eval_Pow F f,
  map_id' := λ n,
  begin
    refine (eval_Pow_of F _).trans _,
    ext A : 2, dsimp,
    rw ← F.map_id, congr' 1,
    ext i j : 2,
    simp only [biproduct.ι_matrix, category.comp_id, biproduct.lift_π, basic_universal_map.id],
    rw biproduct.ι_π,
    split_ifs with hij,
    { cases hij, rw [matrix.one_apply_eq, one_smul, eq_to_hom_refl], },
    { rw [matrix.one_apply_ne, zero_smul], cases i, cases j, dsimp, rintro rfl, exact hij rfl }
  end,
  map_comp' := λ m n o f g, eval_Pow_comp F _ _ }

instance eval_Pow_functor_additive : (eval_Pow_functor F).additive :=
{ map_add' := λ m n f g, by { dsimp [eval_Pow], rw add_monoid_hom.map_add } }

end universal_map

namespace data

open universal_map

def eval_functor : data ⥤ chain_complex (𝒜 ⥤ 𝒜) ℕ :=
(eval_Pow_functor F).map_homological_complex _

def eval_functor' : data ⥤ 𝒜 ⥤ chain_complex 𝒜 ℕ :=
eval_functor F ⋙ homological_complex.functor_eval.flip

-- @[simps]
-- def eval_functor.obj (M : 𝒜) : chain_complex 𝒜 ℕ :=
-- { X := λ n, (Pow (BD.X n) ⋙ F).obj M,
--   d := λ m n, (eval_Pow F (BD.d m n)).app M,
--   shape' := λ i j h, by rw [BD.shape i j h, universal_map.eval_Pow_zero_app],
--   d_comp_d' := λ i j k hij hjk, begin
--     rw [← universal_map.eval_Pow_comp_app],
--     have := BD.d_comp_d i j k,
--     convert universal_map.eval_Pow_zero_app _ _ using 3,
--   end }

-- @[simps {fully_applied := ff}]
-- def eval_functor : 𝒜 ⥤ chain_complex 𝒜 ℕ :=
-- { obj := eval_functor.obj BD F,
--   map := λ A B f,
--   { f := λ n, (Pow (BD.X n) ⋙ F).map f,
--     comm' := λ m n h, by simp only [eval_functor.obj_d, nat_trans.naturality] },
--   map_id' := λ A, by { ext n, exact category_theory.functor.map_id _ _ },
--   map_comp' := λ A B C f g, by { ext n, exact category_theory.functor.map_comp _ _ _ } }

-- @[simps {fully_applied := ff}]
-- def map_eval_functor {BD₁ BD₂ : data} (φ : BD₁ ⟶ BD₂) :
--   BD₁.eval_functor F ⟶ BD₂.eval_functor F :=
-- { app := λ A,
--   { f := λ i, (universal_map.eval_Pow F (φ.f i)).app A,
--     comm' := by { intros, dsimp only [eval_functor_obj, eval_functor.obj_d],
--       simp only [← nat_trans.comp_app, ← eval_Pow_comp F], congr' 2, apply φ.comm } },
--   naturality' := λ A B f, by { ext i : 2, apply nat_trans.naturality } }

end data

namespace package

open universal_map

variables (BD' : package) (A : 𝒜)

def eval_homotopy := (eval_Pow_functor F).map_homotopy BD'.homotopy

def eval_homotopy' (A : 𝒜) :=
(eval_Pow_functor F ⋙ (evaluation _ _).obj A).map_homotopy BD'.homotopy

local attribute [instance] has_binary_biproducts_of_finite_biproducts

@[simps]
def Biprod : 𝒜 ⥤ 𝒜 :=
{ obj := λ A, A ⊞ A,
  map := λ A B f, biprod.map f f,
  map_id' := λ A,
    by ext; simp only [biprod.inl_map, biprod.inr_map, category.id_comp, category.comp_id],
  map_comp' := λ A B C f g,
    by ext; simp only [biprod.inl_map_assoc, biprod.inr_map_assoc, category.assoc] }
.

@[simps {fully_applied := ff}]
def Biprod_iso_Pow_two_components (A : 𝒜) : A ⊞ A ≅ (Pow 2).obj A :=
{ hom := biprod.desc
    (biproduct.ι (λ i : ulift (fin 2), A) ⟨0⟩)
    (biproduct.ι (λ i : ulift (fin 2), A) ⟨1⟩),
  inv := biprod.lift (biproduct.π _ ⟨0⟩) (biproduct.π _ ⟨1⟩),
  hom_inv_id' := begin
    ext;
    simp only [biprod.lift_fst, biprod.lift_snd, biprod.inl_desc_assoc, biprod.inr_desc_assoc,
      biproduct.ι_π_self, category.assoc];
    erw category.id_comp;
    simp only [biprod.inl_fst, biprod.inl_snd, biprod.inr_fst, biprod.inr_snd];
    rw [biproduct.ι_π_ne]; dec_trivial
  end,
  inv_hom_id' := begin
    ext ⟨i⟩ ⟨j⟩,
    erw [category.comp_id],
    simp only [add_comp, comp_add, biprod.lift_desc, category.assoc],
    fin_cases i with [0,1];
    rw [biproduct.ι_π_self_assoc, biproduct.ι_π_ne_assoc, zero_comp],
    swap 2, { dec_trivial },
    swap 3, { dec_trivial },
    { rw add_zero },
    { rw zero_add }
  end }
.

def Biprod_iso_Pow_two : (Biprod : 𝒜 ⥤ 𝒜) ≅ Pow 2 :=
nat_iso.of_components Biprod_iso_Pow_two_components $ λ A B f,
begin
  ext ⟨i⟩;
  simp only [biproduct.ι_map, Biprod_iso_Pow_two_components_hom, Biprod_map, Pow_map,
    biprod.inl_map_assoc, biprod.inl_desc_assoc, biprod.inr_map_assoc, biprod.inr_desc_assoc,
    biprod.inr_map, category.assoc, biprod.inr_desc],
end
.

@[simp] lemma _root_.ulift.up_inj {α : Type*} (a b : α) : ulift.up a = ulift.up b ↔ a = b :=
⟨congr_arg ulift.down, congr_arg ulift.up⟩

@[simp] lemma _root_.ulift.down_inj {α : Type*} (a b : ulift α) : a.down = b.down ↔ a = b :=
⟨by { cases a, cases b, exact congr_arg ulift.up }, congr_arg ulift.down⟩

@[simps]
def Pow_comp_Pow_components (m n : ℕ) (A : 𝒜) :
  (Pow n).obj ((Pow m).obj A) ≅ (Pow (m * n)).obj A :=
{ hom := biproduct.desc $ λ j, biproduct.desc $ λ i,
    biproduct.ι (λ i : ulift (fin _), A) ⟨fin_prod_fin_equiv (i.down, j.down)⟩,
  inv := biproduct.lift $ λ j, biproduct.lift $ λ i,
    biproduct.π (λ i : ulift (fin _), A) ⟨fin_prod_fin_equiv (i.down, j.down)⟩,
  hom_inv_id' := begin
    ext ⟨j⟩ ⟨i⟩ ⟨j'⟩ ⟨i'⟩ : 4,
    erw [biproduct.ι_desc_assoc, category.comp_id],
    simp only [biproduct.ι_desc_assoc, category.assoc, biproduct.lift_π],
    by_cases hj : j = j',
    { subst hj, rw [biproduct.ι_π_self_assoc],
      by_cases hi : i = i',
      { subst hi, rw [biproduct.ι_π_self, biproduct.ι_π_self] },
      { rw [biproduct.ι_π_ne, biproduct.ι_π_ne],
        { exact mt (congr_arg ulift.down) hi },
        { simpa only [equiv.apply_eq_iff_eq, and_true, prod.mk.inj_iff, eq_self_iff_true,
            ulift.up_inj, ne.def] using hi, } } },
    { rw [biproduct.ι_π_ne, biproduct.ι_π_ne_assoc, zero_comp, comp_zero],
      { exact mt (congr_arg ulift.down) hj },
      { simp only [equiv.apply_eq_iff_eq, prod.mk.inj_iff, _root_.ulift.up_inj, ne.def, hj,
          not_false_iff, and_false], } }
  end,
  inv_hom_id' := begin
    ext ⟨k⟩ ⟨k'⟩ : 2,
    erw [category.comp_id],
    simp only [category.assoc, biproduct.lift_desc, sum_comp, comp_sum],
    by_cases h : k = k',
    { subst h,
      rw [biproduct.ι_π_self,
        finset.sum_eq_single (⟨(fin_prod_fin_equiv.symm k).snd⟩ : ulift (fin _)),
        finset.sum_eq_single (⟨(fin_prod_fin_equiv.symm k).fst⟩ : ulift (fin _))],
      { dsimp [- fin_prod_fin_equiv_symm_apply],
        rw [prod.mk.eta, equiv.apply_symm_apply, biproduct.ι_π_self, biproduct.ι_π_self_assoc], },
      { rintro ⟨i⟩ - hi,
        rw [biproduct.ι_π_ne_assoc, zero_comp],
        dsimp [- fin_prod_fin_equiv_symm_apply],
        simp only [ulift.up_inj, ne.def, ← equiv.symm_apply_eq,
          prod.ext_iff, not_and_distrib] at hi ⊢,
        exact or.inl (ne.symm hi) },
      { intro h, exact (h (finset.mem_univ _)).elim },
      { rintro ⟨j⟩ - hj,
        rw finset.sum_eq_zero,
        rintro ⟨i⟩ -,
        rw [biproduct.ι_π_ne_assoc, zero_comp],
        dsimp [- fin_prod_fin_equiv_symm_apply],
        simp only [ulift.up_inj, ne.def, ← equiv.symm_apply_eq,
          prod.ext_iff, not_and_distrib] at hj ⊢,
        exact or.inr (ne.symm hj) },
      { intro h, exact (h (finset.mem_univ _)).elim } },
    { rw [biproduct.ι_π_ne, finset.sum_eq_zero],
      { rintro ⟨j⟩ -,
        rw [finset.sum_eq_zero],
        rintro ⟨i⟩ -,
        by_cases hk : k = fin_prod_fin_equiv (i,j),
        { subst hk,
          rw [biproduct.ι_π_self_assoc, biproduct.ι_π_ne],
          simpa only [ulift.up_inj, ne.def] using h, },
        { rw [biproduct.ι_π_ne_assoc, zero_comp],
          dsimp [- fin_prod_fin_equiv_symm_apply],
          simpa only [ulift.up_inj, ne.def] using h, } },
      { rw [ne.def, ulift.up_inj], exact h } },
  end }
.

def Pow_comp_Pow (m n : ℕ) : (Pow m ⋙ Pow n : 𝒜 ⥤ 𝒜) ≅ Pow (m * n) :=
nat_iso.of_components (Pow_comp_Pow_components m n) $ λ A B f,
begin
  ext ⟨j⟩ ⟨i⟩ ⟨k⟩,
  simp only [biproduct.ι_map, Pow_comp_Pow_components_hom, Pow_map, functor.comp_map,
    biproduct.ι_map_assoc, category.assoc, biproduct.map_π, biproduct.ι_desc_assoc],
end
.

lemma _root_.free_abelian_group.eq_zero_induction
  {α M : Type*} [add_group M] (f : free_abelian_group α → M)
  (h1 : ∀ a, f (free_abelian_group.of a) = 0) (h2 : ∀ x y, f (x + y) = f x + f y) :
  ∀ x, f x = 0 :=
begin
  let F := add_monoid_hom.mk' f h2,
  have hF : ∀ x, F x = f x := λ _, rfl,
  intro x,
  refine free_abelian_group.induction_on x _ h1 _ _,
  { exact F.map_zero },
  { intros, show F _ = 0, rw [F.map_neg, hF, h1, neg_zero], },
  { intros x y hx hy, show F _ = 0, rw [F.map_add, hF, hF, hx, hy, add_zero], },
end

lemma aux' (m n : ℕ) (f : universal_map m n) :
  F.map ((Pow_comp_Pow 2 m).inv.app A ≫ (Pow m).map (Biprod_iso_Pow_two.inv.app A)) ≫
    ((eval_Pow_functor F).map f).app (Biprod.obj A) =
  ((eval_Pow_functor F).map ((mul 2) f)).app A ≫ F.map ((Pow_comp_Pow 2 n).inv.app A ≫
    (Pow n).map (Biprod_iso_Pow_two.inv.app A)) :=
begin
  rw [← sub_eq_zero],
  refine free_abelian_group.eq_zero_induction _ _ _ f; clear f,
  { intro f,
    rw [sub_eq_zero],
    dsimp only [eval_Pow_functor],
    rw [mul_of, eval_Pow_of, eval_Pow_of],
    dsimp only [whisker_right_app, basic_universal_map.eval_Pow_app],
    rw [← F.map_comp, ← F.map_comp],
    congr' 1,
    dsimp only [Pow_comp_Pow, Biprod_iso_Pow_two],
    erw [nat_iso.of_components.inv_app, nat_iso.of_components.inv_app,
      nat_iso.of_components.inv_app],
    dsimp only [Pow_comp_Pow_components_inv, Biprod_iso_Pow_two_components_inv, Pow_map],
    apply category_theory.limits.biproduct.hom_ext,
    rintro ⟨j⟩,
    apply category_theory.limits.biproduct.hom_ext',
    refine equiv.ulift.forall_congr_left'.mpr _,
    refine fin_prod_fin_equiv.forall_congr_left.mp _,
    rintro ⟨b, i⟩,
    rw [biproduct.lift_map, biproduct.lift_matrix, biproduct.lift_π, comp_sum,
      biproduct.lift_map, category.assoc, biproduct.ι_matrix_assoc, biproduct.lift_π],
    rw [finset.sum_eq_single (⟨i⟩ : ulift (fin m)),
      equiv.ulift_symm_apply, ulift.down_up, ulift.down_up, ulift.down_up],
    { rw [category.assoc],
      ext;
      rw [category.assoc, category.assoc, comp_zsmul, zsmul_comp, comp_zsmul, comp_zsmul,
        category.comp_id, category.assoc, category.assoc];
      [rw biprod.lift_fst, rw biprod.lift_snd];
      rw [biproduct.lift_π, biproduct.lift_π, biproduct.lift_π,
        biproduct.ι_π, basic_universal_map.mul_apply, matrix.reindex_linear_equiv_apply,
        matrix.reindex_apply, matrix.minor_apply, ulift.down_up, ulift.down_up,
        matrix.kronecker_map, equiv.symm_apply_apply, equiv.symm_apply_apply];
      simp only [dite_eq_ite, equiv.apply_eq_iff_eq, and_true, prod.mk.inj_iff,
        eq_self_iff_true, ulift.up_inj, eq_to_hom_refl, matrix.one_apply,
        ite_mul, ite_smul, one_mul, zero_mul, zero_smul, @eq_comm _ b, smul_ite, smul_zero];
      congr' 1, },
    { rintro ⟨i'⟩ - hi',
      rw [ne.def, ulift.up_inj, eq_comm] at hi',
      rw [category.assoc],
      ext;
      rw [category.assoc, category.assoc, comp_zsmul, zsmul_comp, comp_zsmul, comp_zsmul,
        category.comp_id, zero_comp];
      [rw biprod.lift_fst, rw biprod.lift_snd];
      rw [biproduct.lift_π, biproduct.ι_π];
      simp only [dite_eq_ite, equiv.apply_eq_iff_eq, and_true, prod.mk.inj_iff,
        eq_self_iff_true, ulift.up_inj, eq_to_hom_refl, equiv.ulift_symm_apply,
        eq_false_intro hi', and_false, if_false, smul_zero], },
    { intro h, exact (h (finset.mem_univ _)).elim } },
  { intros x y,
    simp only [add_monoid_hom.map_add, functor.map_add, comp_add, add_comp, nat_trans.app_add],
    abel }
end

def aux :
  (data.eval_functor' F).obj ((data.mul 2).obj BD'.data) ≅
  Biprod ⋙ (data.eval_functor' F).obj BD'.data :=
nat_iso.of_components (λ A,
  homological_complex.hom.iso_of_components (λ i, begin
      refine F.map_iso _,
      refine (Pow_comp_Pow 2 (BD'.data.X i)).symm.app A ≪≫ _,
      refine (Pow _).map_iso (Biprod_iso_Pow_two.symm.app A)
    end) $ λ i j hij, aux' F A (BD'.data.X i) (BD'.data.X j) (BD'.data.d i j)) $ λ A B f, begin
      ext i,
      dsimp only [data.eval_functor', data.eval_functor, eval_Pow, eval_Pow_functor_obj,
        functor.map_iso_hom, functor.comp_obj, functor.comp_map, functor.flip_obj_map,
        iso.trans_hom, iso.symm_hom, nat_iso.app_hom,
        functor.map_homological_complex_obj_X,
        homological_complex.functor_eval_map_app_f,
        homological_complex.comp_f,
        homological_complex.hom.iso_of_components_hom_f],
      rw [← F.map_comp, ← F.map_comp, ← category.assoc, nat_trans.naturality,
        category.assoc, category.assoc, functor.comp_map, ← functor.map_comp, ← functor.map_comp,
        nat_trans.naturality],
  end
.

lemma foo (A : 𝒜) : _root_.homotopy
  (((data.eval_functor' F).obj BD'.data).map (biprod.fst + biprod.snd : A ⊞ A ⟶ A))
  (((data.eval_functor' F).obj BD'.data).map (biprod.fst : A ⊞ A ⟶ A) +
    ((data.eval_functor' F).obj BD'.data).map (biprod.snd : A ⊞ A ⟶ A)) :=
begin
  refine ((eval_homotopy' F BD' A).symm.comp_left ((aux F BD').inv.app A)).congr _ _ _ _,
  sorry,
  { ext i,
    dsimp [aux, eval_Pow_functor, data.eval_functor', data.eval_functor],
    erw [nat_iso.of_components.inv_app,
      homological_complex.hom.iso_of_components_inv_f],
    dsimp [proj],
    rw [add_monoid_hom.map_sum, fin.sum_univ_two, eval_Pow_of, eval_Pow_of,
      nat_trans.app_add, whisker_right_app, whisker_right_app, comp_add,
      ← F.map_comp, ← F.map_comp],
    sorry }
end


-- #check eval_homotopy F BD'
-- eval_homotopy F BD' :
--  homotopy (((eval_Pow_functor F).map_homological_complex (complex_shape.down ℕ)).map (BD'.data.proj 2))
--    (((eval_Pow_functor F).map_homological_complex (complex_shape.down ℕ)).map (BD'.data.sum 2))

-- #check eval_homotopy' F BD' A
-- eval_homotopy' F BD' A :
--   homotopy
--     (((eval_Pow_functor F ⋙ (evaluation 𝒜 𝒜).obj A).map_homological_complex (complex_shape.down ℕ)).map
--        (BD'.data.proj 2))
--     (((eval_Pow_functor F ⋙ (evaluation 𝒜 𝒜).obj A).map_homological_complex (complex_shape.down ℕ)).map
--        (BD'.data.sum 2))


end package

end breen_deligne
