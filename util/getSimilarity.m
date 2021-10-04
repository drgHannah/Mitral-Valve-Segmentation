function sim = getSimilarity(vec1, vec2, type)

switch type
	case('euclidean')
		sim = norm(vec1(:) - vec2(:),2);
		
	case('manhattan')
		sim = sum(abs(vec1(:) - vec2(:)));
		
	case('cosine')
		sim = dot(vec1(:),vec2(:))/(norm(vec1(:))*norm(vec2(:)));
end



